function model = SrinkageLDA(dataset,train_labels,lambda,sigma)
    %%for two classes (white and black)
    C1=dataset(train_labels==1,:);
    C2=dataset(train_labels==0,:);
    %take their mean and cov matrix
    m1=mean(C1,1);
    m2=mean(C2,1);
    cov1=cov(C1);%or (C1-m1(ones(size(C1,1),1),:))*(C1-m1(ones(size(C1,1),1),:))';
    cov2=cov(C2);
    %apply shrinkage to the covariance matrixes
    S1=(1-lambda)*cov1+lambda*sigma*eye(size(C1,2));
    S2=(1-lambda)*cov2+lambda*sigma*eye(size(C2,2));
    %define the theta and constant
    theta=inv(S1+S2)*(m2-m1)';

    model.t= theta;
    model.c=-theta'*(m1+m2)'/2;
