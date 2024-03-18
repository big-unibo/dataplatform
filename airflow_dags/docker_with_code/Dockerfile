FROM python:3.8

ARG OPTION_1
ARG OPTION_2
# Set working directory
WORKDIR /app

# Copy your Python script to the container
COPY python_script.py /app/

# Install any dependencies if needed
#RUN pip install some_dependency

# Set the command to execute the Python script with command-line options
CMD ["python", "python_script.py", "--option1", "${OPTION_1}", "--option2", "${OPTION_2}"]
