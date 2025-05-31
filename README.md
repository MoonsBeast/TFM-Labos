# TFM-Labos

## General instalation

- Python 3 (Lab Docs)
- Docker and Docker-compose (Lab enviroments)

## Run the labs

1. Clone the repository:

```
git clone https://github.com/MoonsBeast/TFM-Labos
```

2. Access folder:

```
cd TFM-Labos
```

3. Create a virtual env (optional):

```
python3 -m venv venv
source venv/bin/activate
```

4. Run the lab

```
# Compose up (if no service is specified all are activated)
docker-compose -f src/docker-compose.yml up -d [services]

# Compose down
docker-compose -f src/docker-compose.yml down
```

---

# Lab Docs

1. Install mkdocs and mkdocs-material

```
pip install mkdocs mkdocs-material
```

2. Navigate to src

```
cd src
```

3. Serve the documentation

```
mkdocs serve
```

4. Go to the website (`localhost:8000`)

5. Enjoy and learn!