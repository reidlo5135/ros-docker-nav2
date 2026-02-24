# TurtleBot3 Nav2 Run Order

Use separate SSH sessions for long-running commands.

## 0) Common setup (each session)

```bash
source /opt/ros/humble/setup.bash
[ -f /ws/install/setup.bash ] && source /ws/install/setup.bash
export TURTLEBOT3_MODEL=burger
```

## 1) Gazebo world (session A)

```bash
ros2 daemon stop || true
ros2 daemon start
ros2 launch gazebo_ros gazebo.launch.py world:=/opt/ros/humble/share/turtlebot3_gazebo/worlds/turtlebot3_world.world
```

If GUI is unstable, try headless first:

```bash
ros2 launch gazebo_ros gazebo.launch.py gui:=false world:=/opt/ros/humble/share/turtlebot3_gazebo/worlds/turtlebot3_world.world
```

## 2) Spawn TurtleBot3 (session B)

```bash
ros2 run gazebo_ros spawn_entity.py \
  -entity "${TURTLEBOT3_MODEL}" \
  -file "/opt/ros/humble/share/turtlebot3_gazebo/models/turtlebot3_${TURTLEBOT3_MODEL}/model.sdf" \
  -x -2.0 -y -0.5 -z 0.01
  -timeout 120
```

## 3) robot_state_publisher (session C)

Use `xacro`, not `cat`, so `${namespace}` placeholders are expanded.

```bash
ros2 run robot_state_publisher robot_state_publisher \
  --ros-args \
  -p use_sim_time:=true \
  -p robot_description:="$(xacro /opt/ros/humble/share/turtlebot3_description/urdf/turtlebot3_${TURTLEBOT3_MODEL}.urdf)"
```

## 4) Nav2 + SLAM (session D)

```bash
ros2 launch turtlebot3_navigation2 navigation2.launch.py \
  use_sim_time:=True \
  slam:=True
```

## 5) RViz2 (optional separate session)

If Nav2 launch does not open RViz2 automatically:

```bash
rviz2
```

## 6) Save map after exploration

```bash
ros2 run nav2_map_server map_saver_cli -f /ws/maps/my_map
```

This saves:

- `/ws/maps/my_map.yaml`
- `/ws/maps/my_map.pgm`

## 7) Nav2 with existing map (MAP mode)

```bash
ros2 launch turtlebot3_navigation2 navigation2.launch.py \
  use_sim_time:=True \
  slam:=False \
  map:=/ws/maps/my_map.yaml
```

## Timing workaround (when `/spawn_entity` is flaky)

If `spawn_entity` fails with `/spawn_entity unavailable`, this sequence often works better:

1. Run the spawn command first (it waits for the service).
2. In another session, run the Gazebo world launch.
3. Run `robot_state_publisher`.
4. Run Nav2 (`slam:=True`).

## Quick checks

Gazebo spawn service:

```bash
ros2 service list | grep spawn_entity
```

TF static frames:

```bash
ros2 topic echo /tf_static --once | grep base
```

SLAM/map topics:

```bash
ros2 node list | grep slam
ros2 topic list | grep '^/map$'
```
