a <- read.csv("C:/Users/felip/OneDrive/Documents/Quantile Regression/Simulations/Air/lap_20261023/attempt_20261023T171713_511660/summary.csv")
for (i in 1:3) cat(sprintf("%.2f & Onizuka (Laplace) & %.4f (%.4f) & %.5f & %.3f & %.3f & %.3f & %.3f\n",
  a$tau[i], a$mean_MSE[i], a$se_MSE[i], a$mean_CL[i], a$mean_CAA_0.5[i], a$mean_CAA_0.75[i], a$mean_CAA_1[i], a$mean_CAA_1.2[i]))
print(a$n_seeds)
