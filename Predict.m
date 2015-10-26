function predictions = Predict(model,dataset)
    predictions = sign(dataset*model.t+model.c);