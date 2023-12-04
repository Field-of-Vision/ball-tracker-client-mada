<p align="center">
<img src="tracker/data/fig/logoblack.png" alt="Logo">
</p>

<br />
<p align="center">
  <a href="https://github.com/Field-of-Vision">
    <img src="tracker/data/fig/fov_icon.png" alt="Logo" width="100" height="100">
  </a>

  <p align="center">
    Ball tracking desktop client.
    Sends the trajectory of the ball to AWS.
    This application is a placeholder which simmulates the image processing cameras.
  </p>
</p>

### Notes 

* MQTT topic for Dalymount Park is : "dalymount_IRL/pub"

### Controls

* J, K, L for Audio Tutorial for devices 1, 2, and 3 respectively

* Press E when exiting to save the recorded game data .

### Dependencies

* [Processing](https://processing.org/)
* [websockets Processing Library](https://github.com/alexandrainst/processing_websockets)
* [ControlP5 Processing Library](https://github.com/sojamo/controlp5)

### Compilation
```sh
processing-java --sketch=<Project Directory>\tracker --export
```
