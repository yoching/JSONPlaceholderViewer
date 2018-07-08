# JSONPlaceholderViewer
Demo project

## Requirements
This project is using these tools in Run Scripts.
Using different version of these tools might cause compile errors.
Please remove RunScripts if it is impossible to change the version of the tools.

- SwiftLint v0.26.0
- SwiftGen v5.3.0


## Architecture
- MVVM-C based
- Manual DI
  - All depended objects are injected from outside in dependency management objects

![AppArchitecture](./AppArchitecture.png)    


## Reference
- [App Architecture By Manual DI](https://speakerdeck.com/yoching/app-architecture-by-manual-di): my past presentation about the architecture used in this project.
