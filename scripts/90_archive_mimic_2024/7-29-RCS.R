install.packages("rms")
library(rms)

library(ggplot2)

m1 <- X642_sephf_全


dd <- datadist(m1)
options(datadist='dd') 

m3<- cph(Surv(day28, day28_outcome) ~ rcs(TyGbmi,4)+age,x=TRUE, y=TRUE,data = m1)


anova(m3)
#dd$limits$Choline[2] <- 20
#m3=update(m3)
HR<-Predict(m3,TyGbmi,fun=exp,ref.zero = TRUE)
# View(HR)
P1<-ggplot(HR)
P1

P2<-ggplot()+geom_line(data=HR,aes(TyGbmi,yhat),linetype="solid",size=1,alpha = 0.7,colour="darkblue")+  geom_ribbon(data=HR, aes(TyGbmi,ymin = lower, ymax = upper),alpha = 0.1,fill="darkblue")
P2<-P2+theme_classic()+geom_hline(yintercept=1, linetype=2,size=1)+ 
  geom_vline(xintercept=10,linetype=2,size=1)+geom_vline(xintercept=244,linetype=2,size=1)+
  labs(x="TyGbmi", y="HR (95%CI)")
P2


rcsplot(data = X642_sephf_全, outcome="year1_outcome",
        exposure = "TyGbmi", covariates = c("age"))





