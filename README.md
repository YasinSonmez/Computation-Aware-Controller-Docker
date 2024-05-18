Computation-Aware-Controller-Docker Instructions
---------------------------------

Building the Docker Image:
- Standard Build:
  ```
  docker buildx build --no-cache --progress=plain -t <image_name> .
  ```

- On arm64 (M1/M2 Mac) to emulate amd64:
  ```
  docker buildx build --platform linux/amd64 --no-cache --progress=plain -t <image_name> .
  ```

Running the Docker Container:

- Standard build:
  ```
  docker run -it --name <container_name> <image_name> /bin/bash
  ```
- On arm64 (M1/M2 Mac) to emulate amd64:
  ```
  docker run --platform linux/amd64 -it --name <container_name> <image_name> /bin/bash
  ```

A project folder with the simulation files is automatically downloaded, but you can also install it manually anywhere using:
```
git clone https://github.com/YasinSonmez/Inverted-Pendulum.git && cd Inverted-Pendulum/ && git clone https://github.com/YasinSonmez/Scarab-Trace-and-Simulate-Script.git
mkdir build && cd build && cmake -DDynamoRIO_DIR=$DYNAMORIO_HOME/cmake .. && make && cd ..
```

Running Scripts within the Container:
- To execute `main.sh` (Inside the /home/username/Project/Inverted-Pendulum folder) with necessary arguments:
  ```
  ./main.sh <start_idx> <time_horizon> <relative_chip_params_path> <relative_controller_params_path> <exp_name> <PARAM_INDEX> <dynamics_simulation_executable>
  ```
* <start_idx>: Starting index for the operation.
* <time_horizon>: Time horizon for the simulation.
* <relative_chip_params_path>: Relative path to the chip parameter file.
* <relative_controller_params_path>: Relative path to the controller parameter file.
* <exp_name>: Name of the experiment.
* <PARAM_INDEX>: Index of the parameter to use.
* <dynamics_simulation_executable>: Path to the executable for dynamics simulation.

an example command:
```
./main.sh 0 2 chip_params/kaby_lake/l1_size/PARAMS.in_2 controller_parameters/acc/params.json acc_exp_kaby_lake 2 build/acc_controller
```
