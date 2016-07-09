# ExGP

ExGP is a game platform implemented in Elixir to make it easily scalable, distributable, and fault tolerant. The platform consists of a collection of services, each with their own responsibilities. These services are listed below:
- **Bouncer** - This service is responsible for accepting and managing client connections. It is the most complex service.
- **Router** - This service is responsible for routing messages between the various services. It routes messages to clients by sending them to the **Bouncer** service, which in turn sends them to the clients.
- **Auth** - This service is responsible for authentication and account related requests.
- **Chat** - This service is responsible for handling chat between clients.
- **Friends** - This service is responsible for handling client relationships such as friendships and avoidance.

Each of the services follows the same basic design pattern. It contains a *Server* supervisor that watches over several submodule. The *Listener* submodule is a GenServer that simply listens for incoming messages and passes them along to the *Processor*. The *Processor* manages a pool of workers that can be easily scaled, and it spreads out the incoming work to the worker pool. Each of the services has a diagram of its supervision tree in its README.md.

## Environment Setup (Ubuntu 16.04)
#### Installing Elixir
As per the [Elixir Documentation][ElixirInstall]:

Add Erlang Solutions repo:
```
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb  
```  

Run:
```
sudo apt-get update  
```  

Install the Erlang/OTP platform and all of its applications:
```
sudo apt-get install esl-erlang  
```

Install Elixir:
```
sudo apt-get install elixir  
```

#### Installing PostgreSQL
As per [this article][PostgresInstall] from TecAdmin.

Add PostgreSQL Apt Repository:
```
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'  
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -  
```

Install PostgreSQL:
```
sudo apt-get update  
sudo apt-get install postgresql postgresql-contrib  
```

Set the *postgres* user's **DB** password:
```
sudo -u postgres psql
ALTER USER postgres PASSWORD 'postgres';
```

#### Setting Up the PostgreSQL Database
Now that we've installed Postgres and set up the *postgres* user, all we need to do is set up the database. To do this, run the following command from the [db](./db) directory:
```
sudo -u postgres psql -a -f setup_db.sql
```

Optionally, we can populate the database with some initial values. This doesn't need to be done for the platform to run; however, the tests assume that the database is in this state:
```
sudo -u postgres psql -a -f populate_db.sql
```

If the database ever needs to be restored this script makes it easy:
```
sudo -u postgres psql -a -f teardown_db.sql
```

## Running the Platform
The easiest way to run the platform is to navigate to the root directory and run the following commands:
```
mix deps.get && mix deps.compile
iex -S mix
```

This will pull down all of the dependencies, compile them, and then run every service from the same node.

#### Erlang Observer
To allow for the Erlang Observer to be started, we need to pass an extra parameter:
```
iex --erl "-smp" -S mix  
```

### Distributing the Nodes
Each service can also be run from a separate node. To try this out, follow these steps:

1. Open three separate terminal windows to the following directories:
  - [router](./apps/router)
  - [auth](./apps/auth)
  - [bouncer](./apps/bouncer)

2. Run the individual applications using *iex*, giving each node name. The commands are as follows (Respectively):
  - `iex --sname router -S mix`
  - `iex --sname auth -S mix`
  - `iex --sname bouncer -S mix`

3. In the *bouncer* application's *iex* session, type the following commands. Note that *pc-name* will be specific to your own machine:
```
iex(bouncer@pc-name)> Node.self
:"bouncer@pc-name"
iex(bouncer@pc-name)> Node.connect("router@pc-name")
true
iex(bouncer@pc-name)> Node.connect("auth@pc-name")
true
```

4. The nodes are now running and connected. By running the *Node.list* command in any of the *iex* sessions, you should see both of the other nodes:
```
iex(bouncer@pc-name)> Node.list
[:"router@pc-name",:"auth@pc-name"]
```

## Testing the Platform
While it would be possible to simply telnet into the platform, it would be difficult to deal with encoding the messages this way. So, currently the easiest way to test the platform is to use the [JavaScript API][exgp-api-js]. This can be done by running the following commands:
```
$ git clone https://github.com/pcewing/exgp-api-js api
$ cd api
$ npm install
$ npm test
```
[ElixirInstall]: <http://elixir-lang.org/install.html>
[PostgresInstall]: <http://tecadmin.net/install-postgresql-server-on-ubuntu/#>
[exgp-api-js]: <https://github.com/pcewing/exgp-api-js>
