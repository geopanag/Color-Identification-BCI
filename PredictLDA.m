function predictions = PredictLDA(model,dataset)
    predictions = sign(dataset*model.t+model.c);