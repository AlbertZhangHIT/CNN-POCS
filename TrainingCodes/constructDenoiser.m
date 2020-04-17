format compact;
addpath('utilities');

folder = 'TrainSeismicNew';
sigmas = 2:2:30;
numSigma = length(sigmas);
modelName  = 'dilatedDCNN';
CNNdenoiser = cell(1, length(sigmas));
for i = 1 : numSigma
    sigma = sigmas(i);
    subfolder = fullfile(folder, ['sigma_', num2str(sigma)]);
    epoch = findLastCheckpoint(subfolder, modelName);
    modelPath = @(ep) fullfile(subfolder, sprintf([modelName,'-epoch-%d.mat'], ep));
    load(modelPath(epoch)) ;
    [net] = vl_simplenn_mergebnorm(net);
    net = vl_simplenn_move(net, 'cpu');
    CNNdenoiser{i} = net.layers;
end

save('model_seismic_new.mat', 'CNNdenoiser')