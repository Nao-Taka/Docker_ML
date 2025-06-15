# CUDA 12.8 + Python 3.11 環境
# nvidia/以下のcuda~から、Docker hubから探してくるといいでしょう
FROM nvcr.io/nvidia/cuda:12.8.0-cudnn-runtime-ubuntu24.04

# 作業ディレクトリ
WORKDIR /workspace/src

# タイムゾーンの選択を自動化する
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && echo "Asia/Tokyo" > /etc/timezone

# 必要なツールをインストール
# 比較的新しいバージョンのPythonはaptの公式のライブラリに存在しません
# なので新しいPythonが必要な場合はそれがあるディストリビューションからとってきます
# セキュリティ上の問題がある場合は自力でコンパイルすことになるかと思います
# ppaディストリビューションから取ってきた場合はTkinterの関係でトラブルが生じたので
# バージョンをある程度許容してTkinterに対応するようにします
# Python3.12まではディストリビューションにあるようなのでそこから取ってきます
# 仮想環境にPipインストールしないとエラーが出てしまうのでpythonXXX-venvも入れます
# Libx関係はXサーバー関係なようですがよくわかりません…
# x11-appsも入れているのでxeyesというLinuxプログラムが動くはずなので
# ターミナルからのxeyesの実行でエラーが生じるのであればXサーバー関係の通信に問題があるのでしょう
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    git \
    build-essential \
    curl \
    python3.12 \
    python3.12-venv \
    python3-pip \
    libx11-dev \
    libxext-dev \
    libxrender-dev \
    python3-pil \
    python3-tk \
    python3-pil.imagetk \
    tk-dev \
    x11-apps \
    && rm -rf /var/lib/apt/lists/*

# Pythonのシンボリックリンクを作成
# インストールしたPythonのバージョンと同じものを
# 仮想環境のPythonを使うことにするので不要でいいでしょう
# RUN ln -s $(which python3.12) /usr/bin/python

# pipのインストール（distutils なしで問題なく動作する方法）
# pipはapt-getからのインストールに変更しています
# RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | python

#requirements.txtをコンテナ内にコピーする
COPY requirements.txt ./

# 必要なPythonライブラリをインストール

# 共通領域にpipでインストールすると「環境を汚すな」と怒られるようになったようです@Ubuntu24.04以降
#RUN pip install --upgrade --break-system-packages pip
#RUN pip install --no-cache-dir -r --break-system-packages requirements.txt

# なぜか作業ディレクトリには仮想環境を作ってくれませんでした…
# RUN python3 -m venv /workspace/src/venv \
#     && /workspace/src/venv/bin/pip install --upgrade pip \
#     && /workspace/src/venv/bin/pip install --no-cache-dir -r requirements.txt

# /rootにはうまく作れたのでそこにpip installしています
RUN python3.12 -m venv /root/venv \
    && /root/venv/bin/pip install --upgrade pip \
    && /root/venv/bin/pip install --no-cache-dir -r requirements.txt

# Gitの設定を行う
RUN git config --global core.editor 'code --wait'
