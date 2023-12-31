function [class_index, W, consensus_matrix, dispersion]=nmfsc_clustering(data, k_range, sH, iter_num, replica)

% Clustering input data by using sparse NMF
if nargin<3
    sH=0.3;
    iter_num=100;
    replica=10;
elseif nargin<4
    iter_num=100;
    replica=10;
elseif nargin<5
    replica=10;
end

if length(k_range)==1
    replica=1;
    consensus_matrix=[];
    dispersion=[];
end

data_backup=data;

% initialize the clustering
for n=1:length(k_range)
    k=k_range(n);

    for m=1:replica
        [W,H] = nmfsc(data,k,[],sH,iter_num,0);
        [~,c(m,:,n)]=max(H,[],1);
    end
end

if length(k_range)>1
    % evaluate the clustering result
    for n=1:length(k_range)
        k=k_range(n);
        for x=1:size(data,2)
            for y=1:size(data,2)
                condition_matrix=full(sparse(c(:,x,n), c(:,y,n), ones(size(c,1),1),k,k));
                consensus_matrix(x,y,n)=sum(condition_matrix(eye(k)==1))/size(c,1);
            end
        end
        dispersion(n)=sum(sum(4*((consensus_matrix(:,:,n)-0.5).^2)))/size(data,2)^2;
    end

    % find the most consistent clustering result and output the clustering label
    [~,k]=max(dispersion);
    [W,H] = nmfsc(data_backup,k_range(k),[],sH,iter_num,0);
    [~,c]=max(H,[],1);
end

class_index=c;