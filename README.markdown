## jruby-jsvc

Run your jruby application as a unix daemon, taking advantage of the features you get in jsvc - http://commons.apache.org/daemon/ working around the fact that you can't really `fork` from jruby.

With jruby-jsvc you can check your application is basically working while it is still attached to your console.  Once it is, you daemonise it.  This lets you do things like checking your db connection, binding to ports or whatever else your application will need to do to be considered running.

## How to create a jruby-jsvc daemon

1. Install jsvc-jruby.  Check out from source, then run mvn package.  For development purposes, you probably just want to copy `bin/jsvc-wrapper.sh` & `jruby-jsvc.jar` in to you project directory.  I'll leave it to you to decide how you want to distribute to your server (Debian packaging should be coming soon).
1. Take a look at `example/lib/crazy_daemon.rb` - you need to create a Daemon singleton module underneath your application's namespace, something like `Crazy::Daemon`.  This should have a `setup?`, `start` and `stop` method.  `setup?` should return true, and is basically a detection method to check that the daemon was defined and was able to bring up whatever resources it needed to be daemonic.  `start` is called once the daemon has been backgrounded and is your signal to start accepting connections or chomping strings or whatever your application does.
1. Create a boot-up script.  This should require your daemon module and initialize your application so that it is ready to start serving once Daemon.start is called.  There are a couple of examples in example/bin - one which succeeds, the other fails using the DaemonInitException.
1. Create an init.d script that invokes `jsvc-wrapper.bin` (or a copy of it).  You'll need to set a few environment variables, and possibly tweak `jsvc-wrapper.sh` a bit.  For development, you can call `jsvc-wrapper.sh` directly to test running your app as a daemon - Just invoke it from your applications root directory, with something like (works for the example application):

    JRUBY_JSVC_JAR=../target/jsvc-0.1.0.jar JRUBY_DAEMON_DEV=true MODULE_NAME=Crazy SCRIPT_NAME=daemon.rb ../bin/jsvc-wrapper.sh start
