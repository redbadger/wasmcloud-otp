# wasmCloud Host - Web UI Dashboard

This is the web UI dashboard that provides for a basic way to interact with a host and its associated lattice. This web application automatically starts the [host_core](../host_core/README.md) application as a dependency.

To learn more about wasmCloud, please view the [Documentation](https://wasmcloud.dev).


## Building the host

Clone the repo `wasmCloud/wasmcloud-otp` into some suitable development directory

```console
git clone https://github.com/wasmCloud/wasmcloud-otp.git
```


### Language Prerequisites

Install the latest version of [Rust](https://www.rust-lang.org/tools/install) and [Elixir](https://elixir-lang.org/install.html).
Elixir requires the Erlang VM to be installed, but many of the installation methods listed will take care of this for you.

If building the `httpserver` provider from source, you'll also need [Go](https://golang.org/doc/install)

### Environment Prerequisites

1. Since the build of `wasmcloud-otp` will fail on version `16.xx.yy` of NodeJs, you should either install, or switch to, version `14.xx.yy` of NodeJS.

    Typically, a NodeJS version management tool such as `nvm` or `fnm` is used.  For installation details, refer to the documentation for either [Fast Node Manager](https://github.com/Schniz/fnm) or [Node Version Manager](https://github.com/nvm-sh/nvm) (Mac/Linux only)

    Once the Node management tool of your choice has been installed, install the latest Node 14 version, then switch to that version.  E.G.:

    ```console
    fnm install 14
    fnm use 14
    ```

1. Ensure that your Node management tool has the correct shell environment variables.

    In your shell initialisation script (such as `~/.bashrc` or `~/.profile`) add a line suitable for your Node managerment tool

    E.G. if using Fast Node Manager `fnm`, add the line

    ```shell
    eval "$(fnm env)"
    ```

    Continue working in a new terminal window to ensure that the above environment variables are present.

### NATS Messaging Server

1. Install `nats-server`

    ```console
    brew install nats-server
    ```

1. Start the NATS server using the JetStream option

    ```console
    nats-server -js
    ```

    This terminal window is now occupied with the `nats-server` console logs

### Local Server Build

In a new terminal, change into the `wasmcloud-otp` folder, then change into the `assets` folder underneath `wasmcloud_host`

1. `cd wasmCloud/wasmcloud-otp/wasmcloud_host/assets`

1. Run `npm install`.

    As long as you have switched to version `14.xx.yy` of NodeJs, this should run successfully

1. Change up one directory level and run `make run-interactive`.  This will build the wasmCloud server and connect it to your already-started NATS server

1. This terminal window now shows both an Elixir command prompt and from time to time, any wasmCloud console logs

1. You can now point your browser to [localhost:4000](localhost:4000) to see the wasmCloud dashboard. If you want to use a different HTTP port for the dashboard, set the environment variable PORT.

## Building Capability Providers

In the `capability_providers` folder, there are two simple capability providers: `httpserver` and `keyvalue`

Both providers must be built using the supplied `Makefile`, so first change into the `capability_providers` directory

### Building `httpserver`

The `httpserver` provider has been written in Go and can be built using the command:

```console
make httpserver-<os>
```

Where `<os>` is either `linux`, `mac` or `windows`

E.G. To build the Mac `httpserver` provider

```console
make httpserver-mac
```

### Building `keyvalue`

The `keyvalue` provider has been written in Rust and can, if desired, be compiled for targets other than your host OS.

#### Compiling for the Host OS

Make `keyvalue` for your OS as shown above.  E.G. for macOS:

```console
make keyvalue-mac
```

#### Cross-compilation

If you wish to compile `keyvalue` for a different target, you need to use the Rust cross compiler `cross` instead of `cargo`.

1. Identify the target name:

    ```console
    rustup target list
    ```

1. Having identified the desired target, install it using `rustup`

    E.G. for Linux, the target is `x86_64-unknown-linux-gnu`:

    ```console
    rustup install target x86_64-unknown-linux-gnu
    ```

1. Install (or update) the Rust cross compiler `cross`

    ```console
    cargo install cross
    ```

1. Make `keyvalue` for your desired target OS.

    E.G. If you are runing on macOS, but compiling for Linux, run

    ```console
    CARGO=CROSS make keyvalue-linux
    ```

