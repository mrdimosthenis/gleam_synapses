# gleam_synapses

A plug-and-play library for **neural networks** written in **Gleam**!

## Basic usage

### Install synapses

Run `gleam add gleam_synapses` in the directory of your project.

### Import the `Net` module

```gleam
import gleam_synapses/net.{Net}
```

### Create a random neural network by providing its layer sizes

```gleam
let rand_net = net.new([2, 3, 1])
```

* Input layer: the first layer of the network has 2 nodes.
* Hidden layer: the second layer has 3 neurons.
* Output layer: the third layer has 1 neuron.

### Get the json of the random neural network

```gleam
net.to_json(rand_net)
// "[
//   [{\"activationF\" : \"sigmoid\", \"weights\" : [-0.5,0.1,0.8]},
//    {\"activationF\" : \"sigmoid\", \"weights\" : [0.7,0.6,-0.1]},
//    {\"activationF\" : \"sigmoid\", \"weights\" : [-0.8,-0.1,-0.7]}],
//   [{\"activationF\" : \"sigmoid\", \"weights\" : [0.5,-0.3,-0.4,-0.5]}]
// ]"
```


### Create a neural network by providing its json

```gleam
let network = net.from_json("[
   [{\"activationF\" : \"sigmoid\", \"weights\" : [-0.5,0.1,0.8]},
    {\"activationF\" : \"sigmoid\", \"weights\" : [0.7,0.6,-0.1]},
    {\"activationF\" : \"sigmoid\", \"weights\" : [-0.8,-0.1,-0.7]}],
   [{\"activationF\" : \"sigmoid\", \"weights\" : [0.5,-0.3,-0.4,-0.5]}]
 ]")
```

### Make a prediction

```gleam
net.predict(network, [0.2, 0.6])
// [0.49131100324012494]
```

### Train a neural network

```gleam
net.fit(network, 0.1, [0.2, 0.6], [0.9])
```

The `fit` method returns the neural network with its weights adjusted to a single observation.

## Advanced usage

### Fully train a neural network

In practice, for a neural network to be fully trained, it should be fitted with multiple observations, usually by folding over an iterator.

```gleam
[#([0.2, 0.6], [0.9]),
 #([0.1, 0.8], [0.2]),
 #([0.5, 0.4], [0.6])]
|> iterator.from_list
|> iterator.fold(network, fn(acc, t) {
  let #(xs, ys) = t
  net.fit(acc, 0.1, xs, ys)
})
```

### Boost the performance

Every function is efficient because its implementation is based on lazy list
and all information is obtained at a single pass.

For a neural network that has huge layers, the performance can be further improved
by using the parallel counterparts of `predict` and `fit` (`par_predict` and `par_fit`).

### Create a neural network for testing

```gleam
net.new_with_seed([2, 3, 1], 1000)
```

We can provide a `seed` to create a non-random neural network.
This way, we can use it for testing.

### Define the activation functions and the weights

```gleam
import gleam_synapses/fun.{Fun}
import gleam/float

let activation_f = fn(layer_index: Int) -> Fun {
  case layer_index {
    0 -> fun.sigmoid()
    1 -> fun.identity()
    2 -> fun.leaky_re_lu()
    3 -> fun.tanh()
  }
}

let weight_init_f = fn(_: Int) -> Float {
  float.random(0.0, 1.0)
}

let custom_net = net.new_custom([4, 6, 8, 5, 3], activation_f, weight_init_f)
```

* The `activation_f` function accepts the index of a layer and returns an activation function for its neurons.
* The `weight_init_f` function accepts the index of a layer and returns a weight for the synapses of its neurons.

If we don't provide these functions, the activation function of all neurons is sigmoid,
and the weight distribution of the synapses is normal between -1.0 and 1.0.

### Draw a neural network

```gleam
net.to_svg(custom_net)
```

![Network Drawing](https://github.com/mrdimosthenis/gleam_synapses/blob/master/readme_resources/network-drawing.png?raw=true)

With its svg drawing, we can see what a neural network looks like.
The color of each neuron depends on its activation function
while the transparency of the synapses depends on their weight.

### Measure the difference between the expected and predicted values

```gleam
import gleam_synapses/stats

fn exp_and_pred_vals() -> Iterator(#(List(Float), List(Float))) {
  [
    #([0.0, 0.0, 1.0], [0.0, 0.1, 0.9]),
    #([0.0, 1.0, 0.0], [0.8, 0.2, 0.0]),
    #([1.0, 0.0, 0.0], [0.7, 0.1, 0.2]),
    #([1.0, 0.0, 0.0], [0.3, 0.3, 0.4]),
    #([0.0, 0.0, 1.0], [0.2, 0.2, 0.6])
  ]
  |> iterator.from_list
}
```

* Root-mean-square error

```gleam
stats.rmse(exp_and_pred_vals())
// 0.6957010852370435
```

* Classification accuracy score

```gleam
stats.score(exp_and_pred_vals())
// 0.6
```

### Import the `Codec` module

```gleam
import gleam_synapses/codec.{Codec}
```

* One hot encoding is a process that turns discrete attributes into a list of 0.0 and 1.0.
* Minmax normalization scales continuous attributes into values between 0.0 and 1.0.

```gleam
fn setosa() -> Map(String, String) {
  [
    #("petal_length", "1.5"),
    #("petal_width", "0.1"),
    #("sepal_length", "4.9"),
    #("sepal_width", "3.1"),
    #("species", "setosa")
  ]
  |> map.from_list
}

fn versicolor() -> Map(String, String) {
  [
    #("petal_length", "3.8"),
    #("petal_width", "1.1"),
    #("sepal_length", "5.5"),
    #("sepal_width", "2.4"),
    #("species", "versicolor")
  ]
  |> map.from_list
}

fn virginica() -> Map(String, String) {
  [
    #("petal_length", "6.0"),
    #("petal_width", "2.2"),
    #("sepal_length", "5.0"),
    #("sepal_width", "1.5"),
    #("species", "virginica")
  ]
  |> map.from_list
}

fn dataset() -> Iterator(Map(String, String)) {
  iterator.from_list([setosa(), versicolor(), virginica()])
}
```

You can use a `Codec` to encode and decode a data point.

### Create a `Codec` by providing the attributes and the data points

```gleam
let cdc = codec.new([
      #("petal_length", False),
      #("petal_width", False),
      #("sepal_length", False),
      #("sepal_width", False),
      #("species", True))
    ],
    dataset()
)
```

* The first parameter is a list of pairs that define the name and the type (discrete or not) of each attribute.
* The second parameter is an iterator that contains the data points.

### Get the json of the codec

```gleam
let codec_json = codec.to_json(cdc)
// "[
//   {\"Case\" : \"SerializableContinuous\",
//    \"Fields\" : [{\"key\" : \"petal_length\",\"min\" : 1.5,\"max\" : 6.0}]},
//   {\"Case\" : \"SerializableContinuous\",
//    \"Fields\" : [{\"key\" : \"petal_width\",\"min\" : 0.1,\"max\" : 2.2}]},
//   {\"Case\" : \"SerializableContinuous\",
//    \"Fields\" : [{\"key\" : \"sepal_length\",\"min\" : 4.9,\"max\" : 5.5}]},
//   {\"Case\" : \"SerializableContinuous\",
//    \"Fields\" : [{\"key\" : \"sepal_width\",\"min\" : 1.5,\"max\" : 3.1}]},
//   {\"Case\" : \"SerializableDiscrete\",
//    \"Fields\" : [{\"key\" : \"species\",\"values\" : [\"virginica\",\"versicolor\",\"setosa\"]}]}
// ]"
```


### Create a codec by providing its json

```gleam
codec.from_json(codec_json)
```

### Encode a data point

```gleam
let encoded_setosa = codec.encode(cdc, setosa())
// [0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0]
```

### Decode a data point

```gleam
codec.decode(cdc, encoded_setosa)
|> map.to_list
// [
//   #("species", "setosa"),
//   #("sepal_width", "3.1"),
//   #("petal_width", "0.1"),
//   #("petal_length", "1.5"),
//   #("sepal_length", "4.9")
// ]
```
