# Docker

## Preparation

| **Important** |
| --- |
| >> It is important to note that if you do not wish to do any development and only want to deploy the application, none of the steps in Docker will be necessary. Simply copy the .env.example files from the root directory and the ./docker/api path as .env, each in the directory where the example file is located, and run the Docker Composer.
| 


Before launching our composer, we will need to create an SSH private key using the command **ssh-keygen** and add it to our GitHub, GitLab, etc. profile. We should also copy this key to the `ssh-keys` folder since Docker will work with our Git repository via SSH.

We will also copy our `.env.example` file as `.env`, where we will configure the URL of our repository, our Git data, the path to the SSH keys, and various parameters of the containers such as their host names or public ports.

It is important to install the following extensions in our Visual Studio Code for a comfortable and efficient development experience:

- [ms-vscode-remote.vscode-remote-extensionpack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)
- [ms-vscode-remote.remote-containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [xdebug.php-debug](https://marketplace.visualstudio.com/items?itemName=xdebug.php-debug)
- [xdebug.php-pack](https://marketplace.visualstudio.com/items?itemName=xdebug.php-pack)
- [formulahendry.auto-close-tag](https://marketplace.visualstudio.com/items?itemName=formulahendry.auto-close-tag)
- [bmewburn.vscode-intelephense-client](https://marketplace.visualstudio.com/items?itemName=bmewburn.vscode-intelephense-client)
- [zobo.php-intellisense](https://marketplace.visualstudio.com/items?itemName=zobo.php-intellisense)
- [eamodio.gitlens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
- [onecentlin.laravel-blade](https://marketplace.visualstudio.com/items?itemName=onecentlin.laravel-blade)
- [bradlc.vscode-tailwindcss](https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss)
- [mhutchie.git-graph](https://marketplace.visualstudio.com/items?itemName=mhutchie.git-graph)

## Useful Commands

- Delete all containers:
  > docker ps -q -a | xargs docker rm

- Delete all images:
  > docker images -q | xargs docker rmi -f

- Access the console of a container:
  > docker exec -it [container_name] bash
