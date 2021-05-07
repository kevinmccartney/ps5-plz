# For more information, please refer to https://aka.ms/vscode-docker-python
FROM ubuntu:focal

ENV APP_DIR /var/task
ENV PS5_PLZ_ENV LOCAL
WORKDIR $APP_DIR
ENV PATH /var/task/bin:$PATH
ENV PYTHONPATH /var/task/src:/var/task/lib

# Copy deps from the repo
COPY /bin ./bin
COPY requirements.txt .

RUN apt-get update

# set the timezone
# https://stackoverflow.com/a/44333806
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
RUN apt-get install -y tzdata
RUN dpkg-reconfigure --frontend noninteractive tzdata
# install python
RUN apt-get install -y python3.8 \
  python3-pip
# install deps for selenium
# https://stackoverflow.com/a/49710327
RUN apt-get install -y libglib2.0-0 \
    libnss3 \
    libgconf-2-4 \
    libfontconfig1 \
    libx11-dev
# install python deps
RUN pip3 install -r requirements.txt
