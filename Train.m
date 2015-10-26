function model = Train(DatasetName,ModelName,lambda,sigma)

    data=load(strcat(DatasetName,'.mat'));

    model=SrinkageLDA(data.train,data.labels,lambda,sigma);

    data.model_theta=model.t;
    data.model_constant=model.c;
end