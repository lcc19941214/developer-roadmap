# NodeJS 中的进程与线程

## 前置阅读
### [IPC - 进程间通信](https://zh.wikipedia.org/zh-hans/%E8%A1%8C%E7%A8%8B%E9%96%93%E9%80%9A%E8%A8%8A)
**什么是进程间通信？**
进程间通信（IPC，Inter-Process Communication），指至少两个进程或线程间传送数据或信号的一些技术或方法。

**主要的 IPC 方法**

| Method                                                                                                                                              | zh_CN    | Short Description                                                                                                                                                                                                                                                                                                                                                                                                                               | Provided by ([operating systems](https://en.wikipedia.org/wiki/Operating_system) or other environments) |
| :-------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| [File](https://en.wikipedia.org/wiki/Computer_file)                                                                                                 | 文件     | A record stored on disk, or a record synthesized on demand by a file server, which can be accessed by multiple processes.                                                                                                                                                                                                                                                                                                                       | Most operating systems                                                                                  |
| [Signal](https://en.wikipedia.org/wiki/Signal); also [Asynchronous System Trap](https://en.wikipedia.org/wiki/Asynchronous_System_Trap) | 信号     | A system message sent from one process to another, not usually used to transfer data but instead used to remotely command the partnered process.                                                                                                                                                                                                                                                                                                | Most operating systems                                                                                  |
| [Socket](https://en.wikipedia.org/wiki/Network_socket)                                                                                              | 套接字   | Data sent over a network interface, either to a different process on the same computer or to another computer on the network. Stream-oriented ([TCP](https://en.wikipedia.org/wiki/Transmission_Control_Protocol); data written through a socket requires formatting to preserve message boundaries) or more rarely message-oriented ([UDP](https://en.wikipedia.org/wiki/User_Datagram_Protocol), [SCTP](https://en.wikipedia.org/wiki/SCTP)). | Most operating systems                                                                                  |
| [Message queue](https://en.wikipedia.org/wiki/Message_queue)                                                                                        | 消息队列 | A data stream similar to a socket, but which usually preserves message boundaries. Typically implemented by the operating system, they allow multiple processes to read and write to the message queue without being directly connected to each other.                                                                                                                                                                                          | Most operating systems                                                                                  |
| [Anonymous pipe](https://en.wikipedia.org/wiki/Anonymous_pipe)                                                                                      | 管道     | A unidirectional data channel utilizing [standard input and output](https://en.wikipedia.org/wiki/Stdin). Data written to the write-end of the pipe is buffered by the operating system until it is read from the read-end of the pipe. Two-way communication between processes can be achieved by using two pipes in opposite "directions".                                                                                                    | All [POSIX](https://en.wikipedia.org/wiki/POSIX) systems, Windows                                       |
| [Named pipe](https://en.wikipedia.org/wiki/Named_pipe)                                                                                              | 命名管道 | A pipe that is treated like a file. Instead of using standard input and output as with an anonymous pipe, processes write to and read from a named pipe as if it were a regular file.                                                                                                                                                                                                                                                           | All POSIX systems, Windows, AmigaOS 2.0+                                                                |
| [Shared memory](https://en.wikipedia.org/wiki/Shared_memory_(interprocess_communication))                                                           | 共享内存 | Multiple processes are given access to the same block of [memory](https://en.wikipedia.org/wiki/Memory_(computing)) which creates a shared buffer for the processes to communicate with each other.                                                                                                                                                                                                                                             | All POSIX systems, Windows                                                                              |

## child_process
![](/assets/images/2019-12-11-15-58-51.png)

`child_process` 模块提供[四种方式](https://nodejs.org/api/child_process.html#child_process_asynchronous_process_creation)用以创建子进程：

- execFile: 子进程中执行的是非 node 程序，提供一组参数后，执行的结果以回调的形式返回。
- exec: 子进程执行的是非 node 程序，传入一串 shell 命令，执行后结果以回调的形式返回，与 execFile 不同的是 exec 可以直接执行一串 shell 命令。
- spawn: 子进程中执行的是非 node 程序，提供一组参数后，执行的结果以流的形式返回。
- fork: 子进程执行的是 node 程序，提供一组参数后，执行的结果以流的形式返回，与 spawn 不同，fork生成的子进程只能执行 node 应用。

除此之外，`child_process` 也提供了 `execSync`, `execFileSync`, `spawnSync` 三种同步方式执行子进程。

### spawn

spawn 同样是用于执行非 node 应用，且不能直接执行 shell，与 execFile 相比，spawn 执行应用后的结果并不是执行完成后，一次性的输出的，而是以流的形式输出。对于大批量的数据输出，通过流的形式可以介绍内存的使用。

```js
const cp = require('child_process');

// exec
cp.exec('echo hello world', (error, stdout) => {
  console.log('[exec] ' + stdout);
});

// execFile
cp.execFile('echo', ['hi', 'world'], (error, stdout) => {
  console.log('[execFile] ' + stdout);
});

// spawn
cp.spawn('npm', ['--help'], { stdio: 'inherit' });

// spawn
const echo = cp.spawn('echo', ['hello world']);
const wc = cp.spawn('wc', ['-w']);
echo.stdout.pipe(wc.stdin);
wc.stdout.pipe(process.stdout);
```

### fork
node 中提供了 fork 方法，通过 fork 方法在单独的进程中执行 node 程序，并且通过父子间的通信，子进程接受父进程的信息，并将执行后的结果返回给父进程。

```js
// main.js
const cp = require('child_process');
const child = cp.fork('./child.js');

console.log('[main] pid: ' + process.pid);
console.log('[main] child pid: ' + child.pid);

child.on('message', msg => {
  console.log('[main] got a message');
  console.log('[main] message: ' + msg);
});

// 监听子进程断开连接
child.on('exit', () => {
  console.log('[main] child process exited');
});

console.log('[main] sent a message');
child.send('hello world');

setTimeout(() => {
  child.disconnect();
  // process.kill(child.pid)
}, 3000);

```

```js
// child.js
// 父进程 send 第一条消息时，才会开始执行子进程
console.log('[child] ppid: ' + process.ppid);
console.log('[child] pid: ' + process.pid);

process.on('message', function(msg) {
  console.log('[child] got a message');
  process.send('[child] message length is ' + msg.length);
});

setTimeout(() => {
  process.send('[child] heart beat 1');
}, 1000);

setTimeout(() => {
  process.send('[child] heart beat 2');
}, 2000);

// 监听父进程断开连接
process.on('disconnect', () => {
  console.log('[child] disconnect');
});
```

#### 使用 fork 方式构建多进程 web 服务

##### 常见问题
###### 1. 子进程启动失败
**问题原因**

- 进程拥有独立的资源，比如内存、端口
- 根据同一个 server 配置 fork 出来的多个子进程，如果是 http server 服务，占用相同的端口，必然会报错。

**解决方案**

1. 反向代理
2. IPC 传递 socket
3. Cluster

###### 2. 子进程异常退出怎么办
1. 监听子进程退出事件
   - 子进程事件机制
   - `process.on('exit', callback)`
2. 退出后重新 refork 子进程

##### 3. 孤儿进程 / 僵尸进程
> 父进程已退出，子进程还在运行

1. 获取所有子进程
2. 信号机制，守护进程监听 `SIGTERM`，利用 `process.kill` 退出所有子进程


## cluster

A single instance of Node.js runs in a single thread. To take advantage of multi-core systems, the user will sometimes want to launch a cluster of Node.js processes to handle the load.

The cluster module allows easy creation of child processes that all share server ports.

```js
const cluster = require('cluster');
const http = require('http');
const numCPUs = require('os').cpus().length;

if (cluster.isMaster) {
  console.log(`[master] ${process.pid} is running`);

  // Fork workers.
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }

  cluster.on('exit', (worker, code, signal) => {
    console.log(`[master] worker ${worker.process.pid} died`);
  });
} else {
  // Workers can share any TCP connection
  // In this case it is an HTTP server
  http
    .createServer((req, res) => {
      res.writeHead(200);
      res.end(`[worker:${process.pid}] hello world\n`);
    })
    .listen(8000);

  console.log(`[worker] ${process.pid} started`);
}
```

## 参考
- [nodejs 中的子进程，深入解析 child_process 模块和 cluster 模块](https://segmentfault.com/a/1190000016169207)
- [Child Process](https://nodejs.org/api/child_process.html)
- [Cluster](https://nodejs.org/api/cluster.html)
- [Worker Threads](https://nodejs.org/api/worker_threads.html)