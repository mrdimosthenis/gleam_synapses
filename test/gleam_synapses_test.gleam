import gleam_synapses
import gleam/should

pub fn hello_world_test() {
  gleam_synapses.hello_world()
  |> should.equal("Hello, from gleam_synapses!")
}
