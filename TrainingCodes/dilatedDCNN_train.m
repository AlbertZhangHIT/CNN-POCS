function [net, state] = dilatedDCNN_train(net, sigma, imdb, varargin)

%    The function automatically restarts after each training epoch by
%    checkpointing.
%
%    The function supports training on CPU or on one or more GPUs
%    (specify the list of GPU IDs in the `gpus` option).

% Copyright (C) 2014-16 Andrea Vedaldi.
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

%%%-------------------------------------------------------------------------
%%% solvers: SGD(default) and Adam with(default)/without gradientClipping
%%%-------------------------------------------------------------------------

%%% solver: Adam
%%% opts.solver = 'Adam';
opts.beta1   = 0.9;
opts.beta2   = 0.999;
opts.alpha   = 0.01;
opts.epsilon = 1e-8;


%%% solver: SGD
opts.solver = 'SGD';
opts.learningRate = 0.01;
opts.weightDecay  = 0.001;
opts.momentum     = 0.9 ;

%%% GradientClipping
opts.gradientClipping = false;
opts.theta            = 0.005;

%%% specific parameter for Bnorm
opts.bnormLearningRate = 0;

%%%-------------------------------------------------------------------------
%%%  setting for simplenn
%%%-------------------------------------------------------------------------

opts.conserveMemory = true;
opts.mode = 'normal';
opts.cudnn = true ;
opts.backPropDepth = +inf ;
opts.skipForward = false;
opts.numSubBatches = 1;
%%%-------------------------------------------------------------------------
%%%  setting for model
%%%-------------------------------------------------------------------------

opts.batchSize = 128 ;
opts.gpus = [];
opts.numEpochs = 300 ;
opts.modelName   = 'model';
opts.expDir = fullfile('data',opts.modelName) ;
opts.numberImdb   = 1;
opts.imdbDir      = opts.expDir;

%%%-------------------------------------------------------------------------
%%%  setting for logger
%%%-------------------------------------------------------------------------
opts.logInterval = 100;

%%%-------------------------------------------------------------------------
%%%  setting for terminating
%%%-------------------------------------------------------------------------
opts.tolerance = 2e-4;
opts.toltEpochs = 3;

%%%-------------------------------------------------------------------------
%%%  update settings
%%%-------------------------------------------------------------------------

opts = vl_argparse(opts, varargin);
opts.numEpochs = numel(opts.learningRate);
opts.sigma = sigma;

if ~exist(opts.expDir, 'dir'), mkdir(opts.expDir) ; end

%%%-------------------------------------------------------------------------
%%%  Initialization
%%%-------------------------------------------------------------------------

net = vl_simplenn_tidy(net);    %%% fill in some eventually missing values
net.layers{end-1}.precious = 1;
vl_simplenn_display(net, 'batchSize', opts.batchSize) ;

state.getBatch = getBatch ;
state.losses = zeros( ceil(size(imdb.inputs, 4)/opts.batchSize), opts.numEpochs);
state.psnrs = zeros( ceil(size(imdb.inputs, 4)/opts.batchSize), opts.numEpochs);
state.snrs = zeros( ceil(size(imdb.inputs, 4)/opts.batchSize), opts.numEpochs);
state.avgLosses = zeros(1, opts.numEpochs);
%%%-------------------------------------------------------------------------
%%%  Train and Test
%%%-------------------------------------------------------------------------

modelPath = @(ep) fullfile(opts.expDir, sprintf([opts.modelName,'-epoch-%d.mat'], ep));

start = findLastCheckpoint(opts.expDir,opts.modelName) ;
if start >= 1
    fprintf('%s: resuming by loading epoch %d', mfilename, start) ;
    load(modelPath(start)) ;
    net = vl_simplenn_tidy(net) ;
end

%%% load training data
% opts.imdbPath    = fullfile(opts.imdbDir);
% imdb = load(opts.imdbPath) ;
opts.train = find(imdb.set==1);

for epoch = start+1 : opts.numEpochs
    
    %%% Train for one epoch.
    state.epoch = epoch ;
    state.learningRate = opts.learningRate(min(epoch, numel(opts.learningRate)));
    opts.thetaCurrent = opts.theta(min(epoch, numel(opts.theta)));
    if numel(opts.gpus) == 1
        net = vl_simplenn_move(net, 'gpu') ;
    end
    
    state.train = opts.train(randperm(numel(opts.train))) ; %%% shuffle
    [net, state] = process_epoch(net, state, imdb, opts, 'train');
    net.layers{end}.class =[];
    net = vl_simplenn_move(net, 'cpu');
    %%% save current model
    save(modelPath(epoch), 'net', 'state')
    if epoch > 1
        if abs(state.avgLosses(epoch-1) - state.avgLosses(epoch)) < opts.tolerance
            %state.learningRate = state.learningRate * 0.1;
            state.learningRate = 1e-4;
        end
    end
    if epoch > opts.toltEpochs
        if abs((state.avgLosses(epoch) - mean(state.avgLosses(epoch-opts.toltEpochs+1:epoch)))) < opts.tolerance
            break;
        end
    end
end


%%%-------------------------------------------------------------------------
function  [net, state] = process_epoch(net, state, imdb, opts, mode)
%%%-------------------------------------------------------------------------

if strcmp(mode,'train')
    
    switch opts.solver
        
        case 'SGD' %%% solver: SGD
            for i = 1:numel(net.layers)
                if isfield(net.layers{i}, 'weights')
                    for j = 1:numel(net.layers{i}.weights)
                        state.layers{i}.momentum{j} = 0;
                    end
                end
            end
            
        case 'Adam' %%% solver: Adam
            for i = 1:numel(net.layers)
                if isfield(net.layers{i}, 'weights')
                    for j = 1:numel(net.layers{i}.weights)
                        state.layers{i}.t{j} = 0;
                        state.layers{i}.m{j} = 0;
                        state.layers{i}.v{j} = 0;
                    end
                end
            end
            
    end
    
end


subset = state.(mode) ;
batchCount = 0;
num = 0 ;
res = [];
totalLoss = 0;
totalPSNR = 0;
totalSNR = 0;
for t=1:opts.batchSize:numel(subset)
    
    for s=1:opts.numSubBatches
        % get this image batch
        batchStart = t + (s-1);
        batchEnd = min(t+opts.batchSize-1, numel(subset)) ;
        batch = subset(batchStart : opts.numSubBatches : batchEnd) ;
        num = num + numel(batch) ;
        
        if numel(batch) == 0, continue ; end
        
        [inputs,labels] = state.getBatch(imdb, batch, opts.sigma) ;
        
        if numel(opts.gpus) == 1
            inputs = gpuArray(inputs);
            labels = gpuArray(labels);
        end
        
        if strcmp(mode, 'train')
            dzdy = single(1);
            evalMode = 'normal';%%% forward and backward (Gradients)
        else
            dzdy = [] ;
            evalMode = 'test';  %%% forward only
        end
        
        net.layers{end}.class = labels ;
        res = vl_simplenn(net, inputs, dzdy, res, ...
            'accumulate', s ~= 1, ...
            'mode', evalMode, ...
            'conserveMemory', opts.conserveMemory, ...
            'backPropDepth', opts.backPropDepth, ...
            'cudnn', opts.cudnn) ;
        
    end
    
    if strcmp(mode, 'train')
        [state, net] = params_updates(state, net, res, opts, opts.batchSize) ;
    end
    
    lossL2 = gather(res(end).x) ;
    psnr = gather(Cal_BatchPSNR(inputs-res(end-1).x, inputs-labels));
    snr  = gather(Cal_BatchSNR(inputs-res(end-1).x, inputs-labels));
    %%%--------add your code here------------------------
    batchCount = batchCount + 1;
    state.losses(batchCount, state.epoch) = lossL2;
    state.psnrs(batchCount, state.epoch) = psnr;
    state.snrs(batchCount, state.epoch) = snr;
    totalLoss = totalLoss + lossL2;
    totalPSNR = totalPSNR + psnr;
    totalSNR = totalSNR + snr;
    avgLoss = totalLoss / (num/opts.batchSize);
    avgPSNR = totalPSNR / (num/opts.batchSize);
    avgSNR = totalSNR / (num/opts.batchSize);
    state.avgLosses(1, state.epoch) = avgLoss;
    if mod(num/opts.batchSize, opts.logInterval) == 0
        fprintf('%s: epoch %02d : %3d/%3d: loss: %4.4f (avg: %4.4f) : snr: %2.2f: psnr : %2.2f\n', mode, state.epoch,  ...
            fix((t-1)/opts.batchSize)+1, ceil(numel(subset)/opts.batchSize),lossL2, avgLoss, avgSNR, avgPSNR) ;   
    end
    %%%--------------------------------------------------
%     fprintf('%s: epoch %02d : %3d/%3d: loss: %4.4f \n', mode, state.epoch,  ...
%         fix((t-1)/opts.batchSize)+1, ceil(numel(subset)/opts.batchSize),lossL2) ;    
%     fprintf('%s: epoch %02d dataset %02d: %3d/%3d:', mode, state.epoch, mod(state.epoch,opts.numberImdb), ...
%         fix((t-1)/opts.batchSize)+1, ceil(numel(subset)/opts.batchSize)) ;
%     fprintf('error: %f \n', lossL2) ;
    
end


%%%-------------------------------------------------------------------------
function [state, net] = params_updates(state, net, res, opts, batchSize)
%%%-------------------------------------------------------------------------

switch opts.solver
    
    case 'SGD' %%% solver: SGD
        
        for l=numel(net.layers):-1:1
            for j=1:numel(res(l).dzdw)
                if j == 3 && strcmp(net.layers{l}.type, 'bnorm')
                    %%% special case for learning bnorm moments
                    thisLR = net.layers{l}.learningRate(j) - opts.bnormLearningRate;
                    net.layers{l}.weights{j} = vl_taccum(...
                        1 - thisLR, ...
                        net.layers{l}.weights{j}, ...
                        thisLR / batchSize, ...
                        res(l).dzdw{j}) ;
                    
                else
                    thisDecay = opts.weightDecay * net.layers{l}.weightDecay(j);
                    thisLR = state.learningRate * net.layers{l}.learningRate(j);
                    
                    if opts.gradientClipping
                        theta = opts.thetaCurrent/thisLR;
                        state.layers{l}.momentum{j} = opts.momentum * state.layers{l}.momentum{j} ...
                            - thisDecay * net.layers{l}.weights{j} ...
                            - (1 / batchSize) * gradientClipping(res(l).dzdw{j},theta) ;
                        net.layers{l}.weights{j} = net.layers{l}.weights{j} + ...
                            thisLR * state.layers{l}.momentum{j} ;
                    else
                        state.layers{l}.momentum{j} = opts.momentum * state.layers{l}.momentum{j} ...
                            - thisDecay * net.layers{l}.weights{j} ...
                            - (1 / batchSize) * res(l).dzdw{j} ;
                        net.layers{l}.weights{j} = net.layers{l}.weights{j} + ...
                            thisLR * state.layers{l}.momentum{j} ;
                    end
                end
            end
        end
        
        
    case 'Adam'  %%% solver: Adam
        
        for l=numel(net.layers):-1:1
            for j=1:numel(res(l).dzdw)
                
                if j == 3 && strcmp(net.layers{l}.type, 'bnorm')
                    
                    %%% special case for learning bnorm moments
                    thisLR = net.layers{l}.learningRate(j) - opts.bnormLearningRate;
                    net.layers{l}.weights{j} = vl_taccum(...
                        1 - thisLR, ...
                        net.layers{l}.weights{j}, ...
                        thisLR / batchSize, ...
                        res(l).dzdw{j}) ;
                else
                    thisLR = state.learningRate * net.layers{l}.learningRate(j);
                    state.layers{l}.t{j} = state.layers{l}.t{j} + 1;
                    t = state.layers{l}.t{j};
                    alpha = thisLR;
                    lr = alpha * sqrt(1 - opts.beta2^t) / (1 - opts.beta1^t);
                    
                    state.layers{l}.m{j} = state.layers{l}.m{j} + (1 - opts.beta1) .* (res(l).dzdw{j} - state.layers{l}.m{j});
                    state.layers{l}.v{j} = state.layers{l}.v{j} + (1 - opts.beta2) .* (res(l).dzdw{j} .* res(l).dzdw{j} - state.layers{l}.v{j});
                    
                    if opts.gradientClipping
                        theta = opts.thetaCurrent/lr;
                        net.layers{l}.weights{j} = net.layers{l}.weights{j} - lr * gradientClipping(state.layers{l}.m{j} ./ (sqrt(state.layers{l}.v{j}) + opts.epsilon),theta);
                    else
                        net.layers{l}.weights{j} = net.layers{l}.weights{j} - lr * state.layers{l}.m{j} ./ (sqrt(state.layers{l}.v{j}) + opts.epsilon);
                    end
                    
                    % net.layers{l}.weights{j} = weightClipping(net.layers{l}.weights{j},2); % gradually clip the weights
                    
                end
            end
        end
end


%%%-------------------------------------------------------------------------
function epoch = findLastCheckpoint(modelDir,modelName)
%%%-------------------------------------------------------------------------
list = dir(fullfile(modelDir, [modelName,'-epoch-*.mat'])) ;
tokens = regexp({list.name}, [modelName,'-epoch-([\d]+).mat'], 'tokens') ;
epoch = cellfun(@(x) sscanf(x{1}{1}, '%d'), tokens) ;
epoch = max([epoch 0]) ;

%%%-------------------------------------------------------------------------
function A = gradientClipping(A, theta)
%%%-------------------------------------------------------------------------
A(A>theta)  = theta;
A(A<-theta) = -theta;

%%%-------------------------------------------------------------------------
function A = weightClipping(A, theta)
%%%-------------------------------------------------------------------------
A(A>theta)  = A(A>theta) -0.0005;
A(A<-theta) = A(A<-theta)+0.0005;


%%%-------------------------------------------------------------------------
function fn = getBatch
%%%-------------------------------------------------------------------------
fn = @(x,y,z) getSimpleNNBatch(x,y,z);

%%%-------------------------------------------------------------------------
function [inputs,labels] = getSimpleNNBatch(imdb, batch, sigma)
%%%-------------------------------------------------------------------------
inputs = imdb.inputs(:,:,:,batch);
rng('shuffle');
mode = randperm(8);
inputs = data_augmentation(inputs, mode(1));
labels  = sigma/255*randn(size(inputs),'single');
inputs = inputs + labels;



function image = data_augmentation(image, mode)

if mode == 1
    return;
end

if mode == 2 % flipped
    image = flipud(image);
    return;
end

if mode == 3 % rotation 90
    image = rot90(image,1);
    return;
end

if mode == 4 % rotation 90 & flipped
    image = rot90(image,1);
    image = flipud(image);
    return;
end

if mode == 5 % rotation 180
    image = rot90(image,2);
    return;
end

if mode == 6 % rotation 180 & flipped
    image = rot90(image,2);
    image = flipud(image);
    return;
end

if mode == 7 % rotation 270
    image = rot90(image,3);
    return;
end

if mode == 8 % rotation 270 & flipped
    image = rot90(image,3);
    image = flipud(image);
    return;
end







