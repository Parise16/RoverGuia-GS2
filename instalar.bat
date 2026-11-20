@echo off
setlocal DisableDelayedExpansion
pushd "%~dp0" || exit /b 1

set "VENV_PYTHON=%CD%\.venv\Scripts\python.exe"
set "QWEN=qwen3:4b-instruct"
set "ROVERGUIA_OLLAMA="
for /f "delims=" %%I in ('where ollama.exe 2^>nul') do if not defined ROVERGUIA_OLLAMA set "ROVERGUIA_OLLAMA=%%I"
if not defined ROVERGUIA_OLLAMA if exist "%LOCALAPPDATA%\Programs\Ollama\ollama.exe" set "ROVERGUIA_OLLAMA=%LOCALAPPDATA%\Programs\Ollama\ollama.exe"
if not defined ROVERGUIA_OLLAMA (
    echo Instale o Ollama para Windows e execute instalar.bat novamente.
    goto :fim_erro
)

set "ETAPA=criar ou verificar a .venv com Python 3.12"
echo [1/5] Preparando o ambiente Python...
if not exist "%VENV_PYTHON%" call :criar_venv
if not exist "%VENV_PYTHON%" goto :falha
"%VENV_PYTHON%" -c "import sys; sys.exit(sys.version_info[:2] != (3, 12))"
if errorlevel 1 (
    echo A .venv existente precisa usar Python 3.12. Renomeie essa pasta e tente novamente.
    goto :fim_erro
)

set "ETAPA=instalar as bibliotecas Python"
echo [2/5] Instalando as bibliotecas...
"%VENV_PYTHON%" -m pip install "numpy>=2,<2.3" "pandas<3" "matplotlib<4" "opencv-python-headless<5" "pillow>=10" "spacy>=3.8,<3.9" "sentence-transformers>=3,<6" "transformers>=4.46,<5" "pydantic>=2.8,<3" ipykernel
if errorlevel 1 goto :falha

set "ETAPA=instalar o modelo de portugues do spaCy"
echo [3/5] Conferindo o modelo de portugues do spaCy...
"%VENV_PYTHON%" -c "import spacy; spacy.load('pt_core_news_sm')" >nul 2>&1
if errorlevel 1 (
    "%VENV_PYTHON%" -m spacy download pt_core_news_sm
    if errorlevel 1 goto :falha
)

set "ETAPA=baixar e carregar o modelo de embeddings E5"
echo [4/5] Preparando o modelo de embeddings E5...
"%VENV_PYTHON%" -c "import os; from sentence_transformers import SentenceTransformer; SentenceTransformer(os.environ.get('ROVERGUIA_MODELO_EMBEDDING', 'intfloat/multilingual-e5-small'), device='cpu')"
if errorlevel 1 goto :falha

set "ETAPA=iniciar o Ollama"
echo [5/5] Preparando o Qwen3 no Ollama...
"%ROVERGUIA_OLLAMA%" list >nul 2>&1
if errorlevel 1 (
    powershell.exe -NoProfile -NonInteractive -Command "Start-Process -FilePath $env:ROVERGUIA_OLLAMA -ArgumentList 'serve' -WindowStyle Hidden; for ($i=0; $i -lt 15; $i++) { & $env:ROVERGUIA_OLLAMA list 2>$null | Out-Null; if ($LASTEXITCODE -eq 0) { exit 0 }; Start-Sleep -Seconds 1 }; exit 1"
    if errorlevel 1 goto :falha
)
set "ETAPA=baixar %QWEN%"
"%ROVERGUIA_OLLAMA%" show %QWEN% >nul 2>&1
if errorlevel 1 (
    "%ROVERGUIA_OLLAMA%" pull %QWEN%
    if errorlevel 1 goto :falha
)

echo.
echo Instalacao concluida. Abra RoverGuia.ipynb no VS Code.
echo Selecione o kernel .venv ^(Python 3.12^).
popd
exit /b 0

:criar_venv
where py.exe >nul 2>&1
if not errorlevel 1 (
    py -3.12 -c "import sys" >nul 2>&1
    if not errorlevel 1 (
        py -3.12 -m venv .venv
        exit /b
    )
)
python -c "import sys; sys.exit(sys.version_info[:2] != (3, 12))" >nul 2>&1
if not errorlevel 1 (
    python -m venv .venv
    exit /b
)
if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" (
    "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" -m venv .venv
    exit /b
)
where uv.exe >nul 2>&1
if not errorlevel 1 (
    uv venv --python 3.12 --seed .venv
    exit /b
)
echo Instale o Python 3.12 ou o uv e execute instalar.bat novamente.
exit /b 1

:falha
echo Nao foi possivel %ETAPA%. Confira a mensagem acima e tente novamente.
:fim_erro
popd
exit /b 1
