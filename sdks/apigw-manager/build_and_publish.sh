#!/bin/bash
set -uo pipefail

cd sdks/apigw-manager || exit 1

echo "==> 开始构建 apigw-manager..."

# 下载 Python 3.11 standalone
echo "==> 下载 Python 3.11..."
curl -sSL --connect-timeout 30 --retry 3 \
  https://github.com/indygreg/python-build-standalone/releases/download/20240224/cpython-3.11.8+20240224-x86_64-unknown-linux-gnu-install_only.tar.gz \
  -o python3.11.tar.gz
tar -xzf python3.11.tar.gz -C /opt/
export PATH="/opt/python/bin:$PATH"
hash -r

# 确认环境
echo "==> Python 版本："
python --version
echo "==> pip 版本："
/opt/python/bin/python -m pip --version

# 安装 Poetry 和 twine
echo "==> 安装 Poetry 和 twine..."
/opt/python/bin/python -m pip install poetry "twine>=5.0.0" --quiet --root-user-action=ignore

# 提取版本号（使用 Python tomllib 解析，避免 grep 匹配错误）
echo "==> 提取版本号..."
version=$(python -c "import tomllib; t = tomllib.load(open('pyproject.toml', 'rb')); print(t['tool']['poetry']['version'])")
echo ">>> 版本号: ${version}"

# 设置 CI 环境变量（兼容有/无 setEnv 的环境）
if command -v setEnv &>/dev/null; then
    setEnv "tag" "${version}"
else
    echo ">>> [注意] setEnv 命令不可用，跳过设置 CI 环境变量"
    echo "export TAG=${version}" > /tmp/build_tag.env
fi

# 构建
echo "==> 开始构建 wheel..."
rm -rf dist || true
poetry build -f wheel

# 产物拷贝到工作空间 dist/ 目录
echo "==> 拷贝产物到 /data/landun/workspace/dist/..."
mkdir -p /data/landun/workspace/dist
cp dist/* /data/landun/workspace/dist/

# 验证产物
echo "==> 构建产物："
ls -la /data/landun/workspace/dist/

echo "==> 构建完成！"

# 上传步骤（由 CI 变量控制是否执行）
# 注意：这里的 ${{variables.xxx}} 需要由 CI 系统在运行时替换
# 如果直接运行此脚本，需手动设置环境变量

# 上传到腾讯内部 PyPI
if [[ -n "${TENCENT_PYPI_PASS:-}" ]]; then
    echo "==> 上传到腾讯内部 PyPI..."
    /opt/python/bin/python -m twine upload \
      --repository-url http://mirrors.tencent.com/repository/pypi/tencent_pypi/simple \
      /data/landun/workspace/dist/* \
      --username handryhan --password "${TENCENT_PYPI_PASS}" --verbose
else
    echo ">>> [跳过] 未设置 TENCENT_PYPI_PASS，跳过上传到内部 PyPI"
fi

# 上传到官方 PyPI
if [[ -n "${PYPI_ORG_PASS:-}" ]]; then
    echo "==> 上传到官方 PyPI..."
    /opt/python/bin/python -m twine upload \
      --repository-url https://upload.pypi.org/legacy/ \
      /data/landun/workspace/dist/* \
      --username __token__ --password "${PYPI_ORG_PASS}" --verbose
else
    echo ">>> [跳过] 未设置 PYPI_ORG_PASS，跳过上传到官方 PyPI"
fi

echo "==> 全部完成！"
