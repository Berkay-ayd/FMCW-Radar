clear all
clc;
%pkg load control % octave packages
%pkg load signal 


%%%%%%%%%%%%%%%%%%%%%%%%%%%

c = 3e8
%% User Defined Range and Velocity of target

range = 50
vel = -20

range_2 = 100
vel_2 = 20

max_range = 200
range_res = 1
max_vel = 100 % m/s
%% FMCW Waveform Generation


B = c / (2*range_res)
Tchirp = 5.5 * 2 * (max_range/c)  
slope = B/Tchirp
slope_hold = slope

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


  Tx(i)   =  cos(2*pi*(fc*t(i) + (slope*t(i)^2/2 )));
  Rx1(i)   = cos(2*pi*(fc*(t(i) -td(i)) + (slope * ((t(i)^2)/2-td(i)*t(i)))));
  Rx2(i)   = cos(2*pi*(fc*(t(i) -td2(i)) + (slope * (t(i)^2)/2-td2(i)*t(i))));




  noise_matrix(i) = 4 * y1(1);
  Rx_sum(i) = Rx1(i) + Rx2(i);

  Mix(i) = Tx(i) .* Rx_sum(i);


end

%%
plot(t,real(Tx))
grid on
title("Exponential Chirp")
xlabel("Seconds")
ylabel("Amplitude")

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
title('Range from First FFT');
ylabel('Amplitude ');
xlabel('Range [m]');
axis ([0 200 0 500]);



%plotting the range normalized
figure ('Name','Range from First FFT')

% plot FFT output 
plot(signal_fft);
axis ([0 180 0 1]);
title('Range from First FFT');
ylabel('Amplitude (Normalized)');
xlabel('Range [m]');
axis ([0 200 0 1]);




%% RANGE DOPPLER RESPONSE
% The 2D FFT implementation is already provided here. This will run a 2DFFT
% on the mixed signal (beat signal) output and generate a range doppler
% map.You will implement CFAR on the generated RDM

% Range Doppler Map Generation.
% The output of the 2D FFT is an image that has reponse in the range and
% doppler FFT bins. So, it is important to convert the axis from bin sizes
% to range and doppler based on their Max values.

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
title('Amplitude and Range From FFT2');
xlabel('Speed');
ylabel('Range');
zlabel('Amplitude');


%%
surf(doppler_axis,range_axis,abs(RDM))
ylabel("Hz")
shading interp
view(0,90)
yyaxis right
plot(t,1024.^t,"k--")
axis tight
title("Scalogram of Exponential Chirp")
ylabel("Hz")
xlabel("Seconds")

 
 
