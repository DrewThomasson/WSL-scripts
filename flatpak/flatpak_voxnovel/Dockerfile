FROM ubuntu:20.04

# Set noninteractive mode for the timezone selection
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && \
    apt-get install -y flatpak flatpak-builder wget git tzdata && \
    apt-get clean

# Set up Flatpak and Flathub repository
RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

RUN apt-get update

RUN apt-get install -y flatpak flatpak-builder

# Install the required SDK and runtime
RUN flatpak install -y flathub org.freedesktop.Sdk/x86_64/21.08
RUN flatpak install -y flathub org.freedesktop.Platform/x86_64/21.08

# Set up work directory and copy files from the local machine
WORKDIR /app
COPY . /app/

# Run the build when the container starts
CMD ["flatpak-builder", "--install", "--user", "build-dir", "com.example.VoxNovel.yaml"]
