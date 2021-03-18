# gleam_synapses

A **lightweight** library for **neural networks**, written in **Gleam**!

![Network Video](https://github.com/mrdimosthenis/gleam_synapses/blob/master/readme_resources/network-video.gif?raw=true)

## Installation

Add `gleam_synapses` to your `rebar.config` dependencies:

```erlang
{deps, [
    {gleam_synapses, "0.0.1"}
]}.
```

## Import statements

Import the modules `activation_function`, `neural_network`, `data_preprocessor` and `statistics`.

```rust
import gleam_synapses/activation_function
import gleam_synapses/neural_network
import gleam_synapses/data_preprocessor
import gleam_synapses/statistics
```

## Neural Network

### Create a neural network

Call `neural_network.init` and provide the size of each _layer_.

```rust
let layers = [4, 6, 5, 3]
let my_network = neural_network.init(layers)
```

`my_network` has 4 layers. The first layer has 4 input nodes and the last layer has 3 output nodes.
There are 2 hidden layers with 6 and 5 neurons respectively.

### Get a prediction

```rust
let input_values = [1.0, 0.5625, 0.511111, 0.47619]
let prediction = neural_network.prediction(my_network, input_values)
```

`prediction` should be something like `[ 0.8296, 0.6996, 0.4541 ]`.

_Note that the lengths of inputValues and prediction equal to the sizes of input and output layers respectively._

### Fit network

```rust
let learning_rate = 0.5
let expected_output = [0.0, 1.0, 0.0]

let fit_network =
  neural_network.fit(my_network, learning_rate, input_values, expected_output)
```

`fit_network` is a new neural network trained with a single observation. To train a neural network, you should fit with multiple datapoints.

### Create a customized neural network

The _activation function_ of the neurons created with `neural_network.init`, is a sigmoid one.
If you want to customize the _activation functions_ and the _weight distribution_, call `neural_network.customized_init`.

```rust
let activation_f = fn(layer_index) {
  case layer_index {
    0 -> activation_function.sigmoid()
    1 -> activation_function.identity()
    2 -> activation_function.leaky_re_lu()
    _ -> activation_function.tanh()
  }
}

let weight_init_f = fn(layer_index) {
  // https://github.com/mrdimosthenis/minigen
  let random_float =
    minigen.float()
    |> minigen.run
  let random_weight = 1.0 -. 2.0 *. random_float
  let factor = int.to_float(layer_index) +. 1.0

  factor *. random_weight
}

let customized_network =
  neural_network.customized_init(layers, activation_f, weight_init_f)
```

## Visualization

Call `neural_network.to_svg` to take a brief look at its _svg drawing_.

```rust
let svg = neural_network.to_svg(customized_network)
```

![Network Drawing](https://github.com/mrdimosthenis/gleam_synapses/blob/master/readme_resources/network-drawing.png?raw=true)

The color of each neuron depends on its _activation function_
while the transparency of the synapses depends on their _weight_.

## Save and load a neural network

### to_json

Call `neural_network.to_json` on a neural network and get a string representation of it.
Use it as you like. Save `json` in the file system or insert it into a database table.

```rust
let json = neural_network.to_json(customized_network)
```

### of_json

```rust
let neural_network = neural_network.of_json(json)
```

As the name suggests, `neural_network.of_json` turns a json string into a neural network.

## Encoding and decoding

_One hot encoding_ is a process that turns discrete attributes into a list of _0.0_ and _1.0_.
_Minmax normalization_ scales continuous attributes into values between _0.0_ and _1.0_.
You can use `data_preprocessor` for datapoint encoding and decoding.

The first parameter of `data_preprocessor.init` is a list of tuples _(attribute_name, discrete_or_not)_.

```rust
let setosa_datapoint =
  [
    tuple("petal_length", "1.5"),
    tuple("petal_width", "0.1"),
    tuple("sepal_length", "4.9"),
    tuple("sepal_width", "3.1"),
    tuple("species", "setosa"),
  ]
  |> map.from_list
  
let versicolor_datapoint =
  [
    tuple("petal_length", "3.8"),
    tuple("petal_width", "1.1"),
    tuple("sepal_length", "5.5"),
    tuple("sepal_width", "2.4"),
    tuple("species", "versicolor"),
  ]
  |> map.from_list
  
let virginica_datapoint =
  [
    tuple("petal_length", "6.0"),
    tuple("petal_width", "2.2"),
    tuple("sepal_length", "5.0"),
    tuple("sepal_width", "1.5"),
    tuple("species", "virginica"),
  ]
  |> map.from_list
  
let dataset =
  [setosa_datapoint, versicolor_datapoint, virginica_datapoint]
  |> iterator.from_list
  
let my_preprocessor =
  data_preprocessor.init(
    [
      tuple("petal_length", False),
      tuple("petal_width", False),
      tuple("sepal_length", False),
      tuple("sepal_width", False),
      tuple("species", True),
    ],
    dataset,
  )
  
let encoded_datapoints =
  iterator.map(
    dataset,
    fn(x) { data_preprocessor.encoded_datapoint(my_preprocessor, x) },
  )
```

`encoded_datapoints` should be

```rust
[ [ 0.0     , 0.0     , 0.0     , 1.0     , 0.0, 0.0, 1.0 ],
  [ 0.511111, 0.476190, 1.0     , 0.562500, 0.0, 1.0, 0.0 ],
  [ 1.0     , 1.0     , 0.166667, 0.0     , 1.0, 0.0, 0.0 ] ]
```

Save and load the preprocessor by calling `data_preprocessor.to_json` and `data_preprocessor.of_json`.

## Evaluation

To evaluate a neural network, you can call `statistics.root_mean_square_error` and provide the expected and predicted values.

```rust
let expected_with_output_values =
  [
    tuple([0.0, 0.0, 1.0], [0.0, 0.0, 1.0]),
    tuple([0.0, 0.0, 1.0], [0.0, 1.0, 1.0]),
  ]
  |> iterator.from_list
  
let rmse = statistics.root_mean_square_error(expected_with_output_values)
```
