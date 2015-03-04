a = 10;
x = linspace(-a , a , 10000);

B1 = 1./((a^2 + (a/2+x).^2).^(1.5));
B2 =  1./((a^2 + (a/2-x).^2).^(1.5));

close all;
figure 
plot(x , B1);

figure 
plot(x , B2);

figure
plot(x , B2 + B1);