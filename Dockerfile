#Deriving the latest base image
ARG PYTHON_VERSION="3.11"

FROM python:${PYTHON_VERSION}-alpine
ARG DUMB_INIT_VERSION="1.2.5"
RUN apk  --no-cache add git curl

WORKDIR /usr/app/src
COPY requirements.txt .
RUN pip3 install -r requirements.txt
RUN arch=$(arch | sed s/aarch64/aarch64/ | sed s/x86_64/amd64/) && curl -L https://github.com/Yelp/dumb-init/releases/download/v${DUMB_INIT_VERSION}/dumb-init_${DUMB_INIT_VERSION}_$arch -o /bin/dumb-init \
    && chmod +x /bin/dumb-init
COPY ./entrypoint.sh /root/entrypoint.sh
COPY ./run.sh /root/run.sh
RUN chmod 777 /root/entrypoint.sh /root/run.sh
COPY main.py .
COPY SyncIBKR.py .
ENTRYPOINT ["dumb-init", "--"]
CMD /root/entrypoint.sh | while IFS= read -r line; do printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$line"; done;