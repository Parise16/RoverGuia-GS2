# RoverGuia

Projeto da Global Solution 2026.2 da FIAP. O RoverGuia responde a perguntas sobre um percurso a pé da saída de um condomínio até a praça, com foco em pessoas com mobilidade reduzida. A base reúne cinco fotos, dez relatos e referências sobre acessibilidade.

O [notebook](RoverGuia.ipynb) processa as fotos com OpenCV, extrai locais e tipos de obstáculos dos relatos com spaCy e usa embeddings E5 para recuperar os trechos relevantes. O Qwen3 gera a resposta com fontes, e o Pydantic valida o JSON. A avaliação compara 12 perguntas com k=2, k=3 e k=4.

## Executar no Windows

1. Baixe ou clone o repositório e abra a pasta inteira no VS Code com as extensões Python e Jupyter.
2. Instale o Ollama e tenha o Python 3.12 ou o uv disponível. No terminal do VS Code, execute `.\instalar.bat` para preparar a `.venv` e os modelos.
3. Abra `RoverGuia.ipynb`, selecione `.venv/Scripts/python.exe` como kernel e execute as células em ordem.

Os arquivos de entrada estão em [`dados/`](dados/) e [`fotos/`](fotos/). O notebook grava as saídas da execução em `resultados/`.

[Vídeo técnico](https://youtu.be/jxk1Uv9-hW0)
