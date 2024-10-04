clear all
clc;
%pkg load control % octave packages
%pkg load signal 

%% Radar Specifications 
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Frequency of operation = 77GHz
% Max Range = 200m
% Range Resolution = 1 m
% Max Velocity = 100 m/s
%%%%%%%%%%%%%%%%%%%%%%%%%%%

c = 3e8
%% User Defined Range and Velocity of target

range = 30
vel = 0

range_2 = 150
vel_2 = 0

max_range = 200
range_res = 1
max_vel = 100 % m/s
%% FMCW Waveform Generation


B = c / (2*range_res)
Tchirp = 5.5 * 2 * (max_range/c)  
slope = B/Tchirp

%Operating carrier frequency of Radar 
fc= 77e9;             %carrier freq
                                                          
%The number of chirps in one sequence. Its ideal to have 2^ value for the ease of running the FFT
%for Doppler Estimation. 
Nd=128;                   % #of doppler cells OR #of sent periods % number of chirps

%The number of samples on each chirp. 
Nr=1024;                  %for length of time OR # of range cells

% Timestamp for running the displacement scenario for every sample on each
% chirp
t=linspace(0,Nd*Tchirp,Nr*Nd); %total time for samples

%Creating the vectors for Tx, Rx and Mix based on the total samples input.
Tx=zeros(1,length(t)); %transmitted signal
Rx1=zeros(1,length(t)); %received signal
Rx2=zeros(1,length(t)); %received signal
Rx3=zeros(1,length(t)); %received signal
Rx4=zeros(1,length(t)); %received signal
Rx_sum=zeros(1,length(t)); %received signal

S_int = zeros(1,length(t));

Mix = zeros(1,length(t)); %beat signal

%Similar vectors for range_covered and time delay.
r_t=zeros(1,length(t));
td=zeros(1,length(t));

r_t2=zeros(1,length(t));
td2=zeros(1,length(t));

counter = 3;
% white noise
noise_matrix = zeros(1,length(t));
y1 = wgn(1000,1,0);
%% Signal generation and Moving Target simulation
% Running the radar scenario over the time. 


for i=1:length(t)         

  r_t(i) = range + (vel*t(i));
  td(i) = (2 * r_t(i)) / c;

  r_t2(i) = range_2 + (vel_2 * t(i));
  td2(i) = (2 * r_t2(i)) / c;
    
   
  if(mod(i,2))
      slope = B/Tchirp;
     Tx(i)   = cos(2*pi*(fc*t(i) + (slope*t(i)^2)/2 ) );
     Rx1(i)  =cos(2*pi*(fc*(t(i) -td(i)) + (slope * (t(i)-td(i))^2)/2 ) );
     Rx2(i)  =cos(2*pi*(fc*(t(i) -td2(i)) + (slope * (t(i)-td2(i))^2)/2 ) );

     %Rx3 and RX4 is an ghost target
      Rx3(i)   = cos(2*pi*(fc*(t(i) -(td(i)-td2(i))) + (slope * (t(i)-(td(i)-td2(i)))^2)/2 ) );
      Rx4(i)   = cos(2*pi*(fc*(t(i) -(td(i)+td2(i))) + (slope * (t(i)-(td(i)+td2(i)))^2)/2 ) );
  else
    slope = slope * 0.5;
     Tx(i)   = cos(2*pi*(fc*t(i) + (slope*t(i))/2 ) );
     Rx1(i)  =cos(2*pi*(fc*(t(i) -td(i)) + (slope * (t(i)-td(i)))/2 ) );
     Rx2(i)  =cos(2*pi*(fc*(t(i) -td2(i)) + (slope * (t(i)-td2(i)))/2 ) );

     %Rx3 and RX4 is an ghost target
      Rx3(i)   = cos(2*pi*(fc*(t(i) -(td(i)-td2(i))) + (slope * (t(i)-(td(i)-td2(i))))/2 ) );
      Rx4(i)   = cos(2*pi*(fc*(t(i) -(td(i)+td2(i))) + (slope * (t(i)-(td(i)+td2(i))))/2 ) );
  end

 
  Rx_sum(i) = Rx1(i) + Rx2(i) + Rx3(i) + Rx4(i);

  Mix(i) = Tx(i) .* Rx_sum(i);

end


%%
plot(t,real(Tx))
grid on
xlabel("Zaman (saniye)")
ylabel("Genlik")
legend("FM Sinyal")
title("İletilen FM sinyali")



%% RANGE MEASUREMENT


Mix = reshape(Mix, [Nr, Nd]);


%normalize.
signal_fft = fft(Mix, Nr);


% Take the absolute value of FFT output
signal_fft1 = abs(signal_fft);
signal_fft = abs(signal_fft);
signal_fft = signal_fft ./ max(signal_fft); % Normalize


signal_fft = signal_fft(1 : Nr/2-1);

% without normalized
figure ('Name','Range from First FFT')

% plot FFT output 

plot(signal_fft1);
axis ([0 180 0 1]);
title('Fast Fourier Trasnform');
ylabel('Genlik ');
xlabel('Frekans [Hz]');
axis ([0 200 0 500]);


surf(signal_fft1,t);



%plotting the range normalized
figure ('Name','Range from First FFT')

% plot FFT output 
plot(signal_fft);
axis ([0 180 0 1]);
title('İlk FFT ile Uzaklık Tespiti');
ylabel('Genlik ');
xlabel('Uzaklık [m]');
axis ([0 200 0 1]);
grid on



%% RANGE DOPPLER RESPONSE
% The 2D FFT implementation is already provided here. This will run a 2DFFT


Mix=reshape(Mix,[Nr,Nd]);

% 2D FFT using the FFT size for both dimensions.
signal_fft2 = fft2(Mix,Nr,Nd);

% Taking just one side of signal from Range dimension.
signal_fft2 = signal_fft2(1:Nr/2,1:Nd);
signal_fft2 = fftshift (signal_fft2);

RDM = abs(signal_fft2);
RDM = 10*log10(RDM) ;

%use the surf function to plot the output of 2DFFT and to show axis in both
%dimensions

doppler_axis = linspace(-100,100,Nd);
range_axis = linspace(-200,200,Nr/2)*((Nr/2)/400);

figure,surf(doppler_axis,range_axis,RDM);
title('İki Boyutlu FFT ile Hız Uzaklık Tespiti');
xlabel('Hız');
ylabel('Uzaklık');
zlabel('Genlik');

%% 






%%
figure
surf(doppler_axis,range_axis,abs(RDM));
ylabel("Uzaklık")
shading interp
view(0,90)
yyaxis right
plot(t,1024.^t,"k--")
axis tight
title("2-D FFT")
xlabel("Hız")


