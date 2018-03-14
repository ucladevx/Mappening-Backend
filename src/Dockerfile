FROM dora:ml

# Install the rest of the packages
COPY requirements.txt /tmp
RUN cd /tmp && pip install -r requirements.txt

WORKDIR /app
COPY . .
RUN ls -l

EXPOSE 5000
CMD ["python", "app.py"]
