@echo off
@setlocal

for %%m in (0 1) do call :MAKE_FILE %%m

exit /b 0

REM ----------------
:MAKE_FILE
@setlocal

for %%r in (0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0) do call :MAKE_FILE_CORE "%~1" %%r

exit /b 0

REM ----------------
:MAKE_FILE_CORE
@setlocal

set M=%~1
set R=%~2
set OUT_FILE=%~dp0\metal%M%_rough%R%.fx

echo making %OUT_FILE% ...

echo./// @file>"%OUT_FILE%"
echo./// @brief �����x�[�X�}�e���A���}�b�v�Ƀ}�e���A���l�������o�����߂̃V�F�[�_�B>>"%OUT_FILE%"
echo./// @author ���[�`�F>>"%OUT_FILE%"
echo.>>"%OUT_FILE%"
echo./// ���^���b�N�l�B>>"%OUT_FILE%"
echo.#define POSTIBL_PBM_METALLIC %M%.0f>>"%OUT_FILE%"
echo.>>"%OUT_FILE%"
echo./// ���t�l�X�l�B>>"%OUT_FILE%"
echo.#define POSTIBL_PBM_ROUGHNESS %R%f>>"%OUT_FILE%"
echo.>>"%OUT_FILE%"
echo.// ������>>"%OUT_FILE%"
echo.#include "../shader/MaterialRT.fx">>"%OUT_FILE%"

exit /b 0
