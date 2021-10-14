# wasmCloud Host - Web UI Dashboard

This is the web UI dashboard that provides for a basic way to interact with a host and its associated lattice.
This web application automatically starts the [host_core](../host_core/README.md) application as a dependency.

To learn more about wasmCloud, please view the [Documentation](https://wasmcloud.dev).


## Usage

Please refer to the [wasmCloud installation guide](https://wasmcloud.dev/overview/installation/) for instructions on how to install and run wasmCloud.


## Contributing

### Prerequisites

 - Rust
 - Elixir
 - Node v14
 - NATS Messaging Server - refer to the [installation instructions](https://docs.nats.io/nats-server/installation)

### Building and running

1. Install the UI dependencies

    ```bash
    cd wasmCloud/wasmcloud-otp/wasmcloud_host/assets
    npm install
    ```

    This currently only works with Node v14 due to `sass-loader` incompabilities with newer versions of Node.

1. Install project dependencies

    ```bash
    cd ..
    mix deps.get
    ```

1. Start the Host and Web UI Dashboard

    ```bash
    mix phx.server
    ```

    Now you can visit [localhost:4000](http://localhost:4000) from your browser. If you want to use a different HTTP port for the dashboard, set the environment variable PORT, for example:

    ```
    PORT=8000 mix phx.server
    ```
