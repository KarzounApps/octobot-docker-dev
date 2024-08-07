#!/bin/bash

# Define an array of repository URLs
repos=(
    #tiledesk
    # "https://github.com/Tiledesk/tiledesk.git"
    "https://github.com/KarzounApps/octobot-docker-dev.git"
    "https://github.com/KarzounApps/octobot-server.git"
    "https://github.com/KarzounApps/octobot-dashboard.git"
    "https://github.com/KarzounApps/octobot-llm.git"
    "https://github.com/KarzounApps/octobot-design-studio.git"
    "https://github.com/KarzounApps/octobot-chat21-ionic.git"
    "https://github.com/KarzounApps/octobot-chat21-ionic8.git"
    "https://github.com/KarzounApps/octobot-chat21-web-widget.git"
    "https://github.com/KarzounApps/octobot-nginx-proxy.git"
    #chat21
    "https://github.com/KarzounApps/octobot-chat21-http-server.git"
    "https://github.com/KarzounApps/octobot-chat21-server.git"
    "https://github.com/KarzounApps/octobot-chat21-rabbitmq.git"
)

keys=(
   "tiledesk/tiledesk-dashboard"
   "tiledesk/design-studio"
   "chat21/chat21-web-widget"
   "tiledesk/tiledesk-llm"
   "chat21/chat21-ionic"
   "chat21/chat21-ionic8"
   "tiledesk/tiledesk-server"
   "chat21/chat21-http-server"
   "chat21/chat21-server"
   "chat21/chat21-rabbitmq"
   "tiledesk/tiledesk-docker-proxy"
)

values=(
   "tiledesk-dashboard"
   "design-studio"
   "chat21-web-widget"
   "tiledesk-llm"
   "chat21-ionic"
   "chat21-ionic8"
   "tiledesk-server"
   "chat21-http-server"
   "chat21-server"
   "chat21-rabbitmq"
   "tiledesk-docker-proxy"
)

# Directory to clone repositories into
clone_dir="octobot"

# Create the directory if it doesn't exist
mkdir -p "$clone_dir"

# Change to the directory
cd "$clone_dir" || exit

# Function to clone a repository and check out the latest tag
clone_latest_tag() {
  repo_url=$1
  repo_name=$(basename -s .git "$repo_url")

  # Clone the repository without checking out files
  git clone --no-checkout "$repo_url"

  # Change to the repository directory
  cd "$repo_name" || exit

  # Fetch all tags
  git fetch --tags

  # Find the latest tag
  latest_tag=$(git describe --tags "$(git rev-list --tags --max-count=1)")

  # Checkout the latest tag
  git checkout "$latest_tag"

  # Return to the parent directory
  cd ..
}

# Iterate over the array and clone each repository
for repo in "${repos[@]}"; do
    echo "Cloning $repo..."
    clone_latest_tag "$repo"
done

docker_compose_src="octobot-docker-dev/docker-compose.yml"
docker_compose_dest="./docker-compose.yml"

if [ -f "$docker_compose_src" ]; then
    cp "$docker_compose_src" "$docker_compose_dest"
    echo "Copied docker-compose.yml to the current directory as docker-compose.yml"
else
    echo "docker-compose.yml not found in octobot repository"
fi

rm -rf octobot-docker-dev
cd ./octobot

# Function to build Docker images
build_images() {
  echo "Building images..."

  # Build octobot-dashboard
  cd ./octobot-dashboard
  docker build -t octobot-dashboard .
  cd ..

  # Build octobot-design-studio
  cd ./octobot-design-studio
  docker build -t octobot-cds .
  cd ..

  # Build octobot-chat21-ionic
  cd ./octobot-chat21-ionic
  docker build -t octobot-chat21-ionic .
  cd ..

  # Build octobot-chat21-ionic8
  cd ./octobot-chat21-ionic8
  docker build -t octobot-chat21-ionic8 .
  cd ..

  # Build octobot-nginx-proxy
  cd ./octobot-nginx-proxy
  docker build -t octobot-nginx-proxy .
  cd ..

  # Build octobot-server
  cd ./octobot-server
  docker build -t octobot-server .
  cd ..

  # Build octobot-chat21-http-server
  cd ./octobot-chat21-http-server
  docker build -t octobot-chat21-httpserver .
  cd ..

  # Build octobot-chat21-server
  cd ./octobot-chat21-server
  docker build -t octobot-chat21-server .
  cd ..

  # Build octobot-rabbitmq
  cd ./octobot-chat21-rabbitmq
  docker build -t octobot-rabbitmq .
  cd ..

  # Build octobot-llm
  cd ./octobot-llm
  docker build -t octobot-llm .
  cd ..

  echo "Images built successfully."
}

# Function to start Docker containers
start_containers() {
  echo "Starting containers..."
  docker-compose up -d
  echo "Containers started successfully."
}

# Execute functions
build_images
start_containers
