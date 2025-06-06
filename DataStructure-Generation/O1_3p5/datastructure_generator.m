%Convert deepMIMO datasets into data structures in the format required for
%ML ingestion
% sub - 6GHz
file = load('../../DeepMIMOv2_O1_3p5/DeepMIMO_dataset/dataset_3p5.mat');
DeepMIMO_dataset = file.DeepMIMO_dataset;
n_recv = length(DeepMIMO_dataset{1,1}.user);
n_ant = 4;
n_sub = 64;
channel = zeros([n_ant,n_sub,n_recv]);
labels = zeros([1,n_recv]);
DoD_phi = zeros([1,n_recv]);
DoD_theta = zeros([1,n_recv]);
DoA_phi = zeros([1,n_recv]);
DoA_theta = zeros([1,n_recv]);
phase = zeros([1,n_recv]);
ToA = zeros([1,n_recv]);
power = zeros([1,n_recv]);

for i=1:n_ant
    for j=1:n_sub
        for k=1:n_recv
            channel(i,j,k) = DeepMIMO_dataset{1,1}.user{1,k}.channel(1,i,j);
        end
    end
end

for i=1:n_recv
    labels(1,i) = DeepMIMO_dataset{1,1}.user{1,i}.LoS_status;
    DoA_phi(1,i) = DeepMIMO_dataset{1,1}.user{1,i}.DoA_phi;
    DoA_theta(1,i) = DeepMIMO_dataset{1,1}.user{1,i}.DoA_theta;
    DoD_phi(1,i) = DeepMIMO_dataset{1,1}.user{1,i}.DoD_phi;
    DoD_theta(1,i) = DeepMIMO_dataset{1,1}.user{1,i}.DoD_theta;
    phase(1,i) = DeepMIMO_dataset{1,1}.user{1,i}.phase;
    ToA(1,i) = DeepMIMO_dataset{1,1}.user{1,i}.ToA;
    power(1,i) = DeepMIMO_dataset{1,1}.user{1,i}.power;
end

%Constructing data structure
rawData.channel = channel;
rawData.labels = labels;
rawData.DoD_phi = DoD_phi;
rawData.DoD_theta = DoD_theta;
rawData.DoA_phi = DoA_phi;
rawData.DoA_theta = DoA_theta;
rawData.phase = phase;
rawData.ToA = ToA;
rawData.power = power;
s.rawData = rawData;
if ~exist('DataStructures','dir')
    mkdir 'DataStructures';
end
if exist('DataStructures/2p4GHz.mat','file')
    delete 'DataStructures/2p4GHz.mat';
end
save('DataStructures/2p4GHz.mat','-struct','s');
