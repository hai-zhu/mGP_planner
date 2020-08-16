% simple demo to convert a polygon mesh into a voxel representation

% code is 99.99% based on
% [1] http://www.mathworks.com/matlabcentral/fileexchange/24086-polygon2voxel
% [2] http://www.mathworks.com/matlabcentral/fileexchange/21044-3d-voxelizer

%   % Compile the c-coded function
%   mex polygon2voxel_double.c -v

load model;

vertices = vertices - repmat(mean(vertices,1),size(vertices,1),1);

FV.faces = faces;
FV.vertices = vertices;

Volume=polygon2voxel(FV,[100 100 100],'auto');

%% visualization 1
figure
[X,Y,Z]=ind2sub(size(Volume),find(Volume(:)));
plot3(X,Y,Z,'.');
axis equal;
xlabel('x');
ylabel('y');
zlabel('z');

%% visualization 2
% 3d pirnter style visualization to add layer by layer
plot3D(Volume)

figure
%% visualization 3
for i=1:size(Volume,1)
    imagesc(squeeze(Volume(i,:,:)));
    axis equal;
    axis tight;
    axis off
    title(i);
%     pause(0.1);
end

for i=1:size(Volume,2)
    imagesc(squeeze(Volume(:,i,:)));
    axis equal;
    axis tight;
    axis off
    title(i);
%     pause(0.1);
end

for i=1:size(Volume,3)
    imagesc(squeeze(Volume(:,:,i)));
    axis equal;
    axis tight;
    axis off
    title(i);
%     pause(0.1);
end
