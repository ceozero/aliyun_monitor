FROM python:3.12-alpine

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TZ=Asia/Shanghai

RUN apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone

WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./
COPY docker/entrypoint.sh /usr/local/bin/aliyun-monitor
RUN chmod +x /usr/local/bin/aliyun-monitor \
    && mkdir -p /opt/scripts

VOLUME ["/opt/scripts"]
ENTRYPOINT ["/usr/local/bin/aliyun-monitor"]
