In this project I create FMCW-based radar systems that detect the range and velocity of the object.
We also want to detect ghost targets in the radar systems. This ghost target appears in a multi-target environment. We create some algorithms to determine this ghost target. I use Matlab to simulate my software both single and multi-target detection. I also make some hardware simulations in an LT-SPICE program.

This project aims to use FMCW technology in a radar system to detect both therange and speed of vehicles. FMCW radar systems can use various modulation methods, but in our project we used a linear frequency modulated (chirp) signal. Linearly varying the frequency of the transmitted signal over time creates a consistent chirp rate. The reasons for choosing this modulation technique are easy implementation and cost-effectiveness compared to other modulation techniques. Frequency Modulated Continuous Wave (FMCW) radar is a critical technology in modern autonomous driving systems. FMCW radar systems use a continuously transmitted signal whose frequency varies linearly over time, known as the linear frequency modulated (FM) or chirp signal. The chirp signal bandwidth determines the maximum detectable range and speed of the target. The resolution of this system is determined by the frequency of the system. Higher frequency has better resolution than lower frequency. Reflected signals from targets are mixed with the transmitted signal to produce pulse frequencies, which are then analyzed using the Fast Fourier Transform (FFT) algorithm to extract range and speed information of the target. With this signal processing technique, FMCW radar can determine the speed and range of vehicles and other objects at an acceptable level.

FMCW radar presents significant advantages such as high resolution, robustnessin adverse weather conditions, and the ability to detect both stationary and moving objects. These features make it critical for automotive applications where it increases safety and reliability. Increasing the frequency of the system requires more work in terms of cost and complexity. In general, the FMCW radar is set up to work with other systems in the vehicle. By utilizing multiple systems instead of a singular one, autonomous driving becomes significantly safer


![fm](https://github.com/user-attachments/assets/e28bace3-dd84-482f-be81-d498bbb920b3)
Sending FM singal which is created in a matlab

![1fft](https://github.com/user-attachments/assets/79a6f10d-5caf-4057-9a42-82efb299f051)

Single target detection range value of an target
![Untitled-1](https://github.com/user-attachments/assets/51397457-76a2-484f-b1b0-0a402008a014)

Single target detection with a 2-D FFT range and veleocity of an target. In FMCW radar, a 2D FFT is used to obtain both range and Doppler simultaneously. Range and Doppler information provides a two-dimensional map, generally
referred to as a range-Doppler map which helps define ranges and velocities of targets.

For a multi target detection it is create ghsot target to get rid of the ghost target we cahnge the chirp intantenous freauncy with this chaange it can detec the ghost target.
