/// @file
/// @brief IBL�|�X�g�G�t�F�N�g�̃��C���t�@�C���B
/// @author ���[�`�F

// ���}�b�v�֘A��`
#include "shader/EnvMapCommon.h"

////////////////////
// �ݒ肱������
////////////////////

/// �ʏ�`�挋�ʋL�^�p�e�N�X�`���̃t�H�[�}�b�g�B
#define POSTIBL_ORGCOLOR_RT_FORMAT "A8R8G8B8"

/// ���}�b�v�e�N�X�`���̏c�����B
///
/// - 512, 1024, 2048 ������BPC�X�y�b�N�Ɏ��M������Ȃ� 4096 ���A���B
/// - ���R�Ȃ���T�C�Y���傫���ق��Y��ɂȂ邪���ׂ��傫���B
#define POSTIBL_ENVMAP_RT_SIZE 2048

/// ���J���[�}�b�v�e�N�X�`���̃t�H�[�}�b�g�B
#define POSTIBL_ENVCOLOR_RT_FORMAT "A16B16G16R16F"

/// @brief ���}�b�v�W�J��e�N�X�`���̉����B
///
/// - 512, 1024, 2048 �̂����ꂩ�B�c���͂���̔����ɂȂ�B
/// - ���R�Ȃ���T�C�Y���傫���ق��Y��ɂȂ邪���ׂ��傫���B
/// - ��{�I�ɂ� POSTIBL_ENVMAP_RT_SIZE �Ɠ����������菬��������B
#define POSTIBL_ENVMAP_DEST_WIDTH 1024

/// ���}�b�v�W�J��e�N�X�`���̃t�H�[�}�b�g�B
#define POSTIBL_ENVMAP_DEST_FORMAT "A16B16G16R16F"

/// �����x�[�X�}�e���A���}�b�v�e�N�X�`���̃t�H�[�}�b�g�B
#define POSTIBL_MATERIAL_RT_FORMAT "A16B16G16R16F"

/// �A���x�h�}�b�v�e�N�X�`���̃t�H�[�}�b�g�B
#define POSTIBL_ALBEDO_RT_FORMAT "A8R8G8B8"

/// �ʒu�}�b�v�e�N�X�`���̃t�H�[�}�b�g�B
#define POSTIBL_POSITION_RT_FORMAT "A16B16G16R16F"

/// �@���}�b�v�e�N�X�`���̃t�H�[�}�b�g�B
#define POSTIBL_NORMAL_RT_FORMAT "A16B16G16R16F"

/// �[�x�}�b�v�e�N�X�`���̃t�H�[�}�b�g�B
#define POSTIBL_DEPTH_RT_FORMAT "R32F"

/// Hammersley ��Y���W�����O�v�Z�����e�N�X�`���̃T���v�����B
#define POSTIBL_HAMMERSLEY_Y_SAMPLE_COUNT 1024

/// SSR+IBL�ł̃T���v�����O�񐔁B
#define POSTIBL_REFLECTION_SAMPLE_COUNT 32

/// SSR�̃��C�g���[�X�X�e�b�v�񐔁B
#define POSTIBL_SSR_STEP_COUNT 8

/// SSR�̃��C�g���[�X�X�e�b�v�̃I�t�Z�b�g�ʁB -0.5f �ȏ� +0.5f �ȉ��B
#define POSTIBL_SSR_STEP_OFFSET 0.0f

////////////////////
// �ݒ肱���܂�
////////////////////
// �ϐ���`��������
////////////////////

/// �|�X�g�G�t�F�N�g�p��`�B
float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8f;

/// �ʏ�`�挋�ʋL�^�p�e�N�X�`���B
texture2D OrgColorRT : RENDERCOLORTARGET <
    float2 ViewPortRatio = { 1, 1 };
    string Format = POSTIBL_ORGCOLOR_RT_FORMAT;
    int MipLevels = 1; >;

/// �ʏ�`�挋�ʋL�^�p�e�N�X�`���̃T���v���B
sampler2D OrgColorRTSampler =
    sampler_state
    {
        Texture = <OrgColorRT>;
        MinFilter = LINEAR;
        MagFilter = LINEAR;
        MipFilter = LINEAR;
        AddressU = CLAMP;
        AddressV = CLAMP;
    };

/// �ʏ�`�挋�ʋL�^�p�f�v�X�o�b�t�@�B
texture2D OrgColorDS : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = { 1, 1 };
    string Format = "D24S8"; >;

/// ���J���[�}�b�v�e�N�X�`���B
texture2D IBL_EnvColor : OFFSCREENRENDERTARGET <
    string Description = "Environment color map for PostIBL";
    int Width = (POSTIBL_ENVMAP_RT_SIZE);
    int Height = (POSTIBL_ENVMAP_RT_SIZE);
    float4 ClearColor = { 0, 0, 0, 0 };
    float ClearDepth = 1;
    string Format = POSTIBL_ENVCOLOR_RT_FORMAT;
    int MipLevels = 1;
    string DefaultEffect =
        "self=hide;"
#ifdef MIKUMIKUMOVING
        "*=shader/EnvMapRT_MMM.fx";
#else // MIKUMIKUMOVING
        "*=shader/EnvMapRT_MME.fx";
#endif // MIKUMIKUMOVING
    >;

/// ���J���[�}�b�v�e�N�X�`���̃T���v���B
sampler2D EnvColorSampler =
    sampler_state
    {
        Texture = <IBL_EnvColor>;
        MinFilter = POINT;
        MagFilter = POINT;
        MipFilter = POINT;
        AddressU = WRAP;
        AddressV = CLAMP;
    };

/// ���}�b�v�W�J��e�N�X�`���B
texture2D EnvMapRT : RENDERCOLORTARGET <
    int Width = (POSTIBL_ENVMAP_DEST_WIDTH);
    int Height = (POSTIBL_ENVMAP_DEST_WIDTH) / 2;
    string Format = POSTIBL_ENVMAP_DEST_FORMAT;
    int MipLevels = 1; >;

/// ���}�b�v�W�J��e�N�X�`���̃T���v���B
sampler2D EnvMapRTSampler =
    sampler_state
    {
        Texture = <EnvMapRT>;
        MinFilter = LINEAR;
        MagFilter = LINEAR;
        MipFilter = LINEAR;
        AddressU = WRAP;
        AddressV = CLAMP;
    };

/// �����x�[�X�}�e���A���}�b�v�e�N�X�`���B
texture2D IBL_Material : OFFSCREENRENDERTARGET <
    string Description = "Material map for PostIBL";
    float2 ViewPortRatio = { 1, 1 };
    float4 ClearColor = { 0, 0, 0, 0 };
    float ClearDepth = 1;
    string Format = POSTIBL_MATERIAL_RT_FORMAT;
    int MipLevels = 1;
    string DefaultEffect =
        "self=hide;"
        "*_m0r0.0.*=material/metal0_rough0.0.fx;"
        "*_m0r0.1.*=material/metal0_rough0.1.fx;"
        "*_m0r0.2.*=material/metal0_rough0.2.fx;"
        "*_m0r0.3.*=material/metal0_rough0.3.fx;"
        "*_m0r0.4.*=material/metal0_rough0.4.fx;"
        "*_m0r0.5.*=material/metal0_rough0.5.fx;"
        "*_m0r0.6.*=material/metal0_rough0.6.fx;"
        "*_m0r0.7.*=material/metal0_rough0.7.fx;"
        "*_m0r0.8.*=material/metal0_rough0.8.fx;"
        "*_m0r0.9.*=material/metal0_rough0.9.fx;"
        "*_m0r1.0.*=material/metal0_rough1.0.fx;"
        "*_m1r0.0.*=material/metal1_rough0.0.fx;"
        "*_m1r0.1.*=material/metal1_rough0.1.fx;"
        "*_m1r0.2.*=material/metal1_rough0.2.fx;"
        "*_m1r0.3.*=material/metal1_rough0.3.fx;"
        "*_m1r0.4.*=material/metal1_rough0.4.fx;"
        "*_m1r0.5.*=material/metal1_rough0.5.fx;"
        "*_m1r0.6.*=material/metal1_rough0.6.fx;"
        "*_m1r0.7.*=material/metal1_rough0.7.fx;"
        "*_m1r0.8.*=material/metal1_rough0.8.fx;"
        "*_m1r0.9.*=material/metal1_rough0.9.fx;"
        "*_m1r1.0.*=material/metal1_rough1.0.fx;"
        "*=material/none.fx;"; >;

/// �����x�[�X�}�e���A���}�b�v�e�N�X�`���̃T���v���B
sampler2D MaterialSampler =
    sampler_state
    {
        Texture = <IBL_Material>;
        MinFilter = LINEAR;
        MagFilter = LINEAR;
        MipFilter = LINEAR;
        AddressU = WRAP;
        AddressV = CLAMP;
    };

/// �A���x�h�}�b�v�e�N�X�`���B
texture2D IBL_Albedo : OFFSCREENRENDERTARGET <
    string Description = "Albedo map for PostIBL";
    float2 ViewPortRatio = { 1, 1 };
    float4 ClearColor = { 0, 0, 0, 0 };
    float ClearDepth = 1;
    string Format = POSTIBL_ALBEDO_RT_FORMAT;
    int MipLevels = 1;
    string DefaultEffect =
        "self=hide;"
        "*=shader/AlbedoRT.fx"; >;

/// �A���x�h�}�b�v�e�N�X�`���̃T���v���B
sampler2D AlbedoSampler =
    sampler_state
    {
        Texture = <IBL_Albedo>;
        MinFilter = LINEAR;
        MagFilter = LINEAR;
        MipFilter = LINEAR;
        AddressU = CLAMP;
        AddressV = CLAMP;
    };

/// �ʒu�}�b�v�e�N�X�`���B
texture2D IBL_Position : OFFSCREENRENDERTARGET <
    string Description = "Position map for PostIBL";
    float2 ViewPortRatio = { 1, 1 };
    float4 ClearColor = { 0, 0, 0, 0 };
    float ClearDepth = 1;
    string Format = POSTIBL_POSITION_RT_FORMAT;
    int MipLevels = 1;
    string DefaultEffect =
        "self=hide;"
        "*=shader/PositionRT.fx"; >;

/// �ʒu�}�b�v�e�N�X�`���̃T���v���B
sampler2D PositionSampler =
    sampler_state
    {
        Texture = <IBL_Position>;
        MinFilter = LINEAR;
        MagFilter = LINEAR;
        MipFilter = LINEAR;
        AddressU = CLAMP;
        AddressV = CLAMP;
    };

/// �@���}�b�v�e�N�X�`���B
texture2D IBL_Normal : OFFSCREENRENDERTARGET <
    string Description = "Normal map for PostIBL";
    float2 ViewPortRatio = { 1, 1 };
    float4 ClearColor = { 0, 0, 0, 0 };
    float ClearDepth = 1;
    string Format = POSTIBL_NORMAL_RT_FORMAT;
    int MipLevels = 1;
    string DefaultEffect =
        "self=hide;"
        "*=shader/NormalRT.fx"; >;

/// �@���}�b�v�e�N�X�`���̃T���v���B
sampler2D NormalSampler =
    sampler_state
    {
        Texture = <IBL_Normal>;
        MinFilter = LINEAR;
        MagFilter = LINEAR;
        MipFilter = LINEAR;
        AddressU = CLAMP;
        AddressV = CLAMP;
    };

/// �[�x�}�b�v�e�N�X�`���B
texture2D IBL_Depth : OFFSCREENRENDERTARGET <
    string Description = "Depth map for PostIBL";
    float2 ViewPortRatio = { 1, 1 };
    float4 ClearColor = { 1, 1, 1, 0 };
    float ClearDepth = 1;
    string Format = POSTIBL_DEPTH_RT_FORMAT;
    int MipLevels = 1;
    string DefaultEffect =
        "self=hide;"
        "*=shader/DepthRT.fx"; >;

/// �[�x�}�b�v�e�N�X�`���̃T���v���B
sampler2D DepthSampler =
    sampler_state
    {
        Texture = <IBL_Depth>;
        MinFilter = LINEAR;
        MagFilter = LINEAR;
        MipFilter = LINEAR;
        AddressU = CLAMP;
        AddressV = CLAMP;
    };

/// ���}�b�v�W�J�p�e�N�X�`���t�@�C���p�X�쐬�}�N���B
#define POSTIBL_ENVMAP_DEST_TEXNAME(width) "texture/equirect_to_cube_" #width ".dds"

/// ���}�b�v�W�J�p�e�N�X�`���B
texture2D EnvDestTex <
    string ResourceName = POSTIBL_ENVMAP_DEST_TEXNAME(POSTIBL_ENVMAP_DEST_WIDTH); >;

/// ���}�b�v�W�J�p�e�N�X�`���̃T���v���B
sampler2D EnvDestTexSampler =
    sampler_state
    {
        Texture = <EnvDestTex>;
        MinFilter = POINT;
        MagFilter = POINT;
        MipFilter = POINT;
        AddressU = WRAP;
        AddressV = CLAMP;
    };

/// ��BRDF�������O�v�Z���� Look-up �e�N�X�`���B
texture2D BrdfTex < string ResourceName = "texture/lookup_brdf.dds"; >;

/// ��BRDF�������O�v�Z���� Look-up �e�N�X�`���̃T���v���B
sampler BrdfTexSampler =
    sampler_state
    {
        Texture = <BrdfTex>;
        MinFilter = LINEAR;
        MagFilter = LINEAR;
        MipFilter = LINEAR;
        AddressU = CLAMP;
        AddressV = CLAMP;
    };

/// Hammersley ��Y���W�����O�v�Z�����e�N�X�`���B
texture2D HammersleyYTex < string ResourceName = "texture/hammersley_y.dds"; >;

/// Hammersley ��Y���W�����O�v�Z�����e�N�X�`���̃T���v���B
sampler HammersleyYTexSampler =
    sampler_state
    {
        Texture = <HammersleyYTex>;
        MinFilter = POINT;
        MagFilter = POINT;
        MipFilter = POINT;
        AddressU = CLAMP;
        AddressV = CLAMP;
    };

/// ���[���h�r���[�v���W�F�N�V�����}�g���N�X�B
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;

/// �X�N���[�����W�� W �l�B
static float ScreenW = mul(float4(0, 0, 0, 1), WorldViewProjMatrix).w;

/// �r���[�v���W�F�N�V�����}�g���N�X�B
float4x4 ViewProjMatrix : VIEWPROJECTION;

/// �J�����ʒu�B
float3 CameraPosition : POSITION < string Object = "Camera"; >;

/// �r���[�|�[�g�T�C�Y�B
float2 ViewportSize : VIEWPORTPIXELSIZE;

/// �r���[�|�[�g�I�t�Z�b�g�B
static float2 ViewportOffset = float2(0.5f, 0.5f) / ViewportSize;

/// ���}�b�v�̃J�����ʒu�B
float3 EnvCameraPosition : CONTROLOBJECT < string name = "(self)"; >;

/// ���}�b�v�̃r���[�|�[�g�I�t�Z�b�g�B
static float2 EnvViewportOffset =
    {
        0.5f / (POSTIBL_ENVMAP_DEST_WIDTH),
        1.0f / (POSTIBL_ENVMAP_DEST_WIDTH),
    };

/// ���}�b�v�̔w�i�F�B
#ifdef MIKUMIKUMOVING
float3 EnvBackColor : BACKGROUNDCOLOR;
#else // MIKUMIKUMOVING
float3 EnvBackColor = { 1, 1, 1 };
#endif // MIKUMIKUMOVING

/// SSR�̓K�p�x�����B
float SSRIntensity : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

/// SSR�̃��t�l�X�t�F�[�h�I�[�l�̊�l�B
float SSRMaxRoughnessBase : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;

/// SSR�̃��t�l�X�t�F�[�h�I�[�l�B�f�t�H���g�� 1 �ɂȂ�B
static float SSRMaxRoughness = max(SSRMaxRoughnessBase * 0.1f, 0.001f);

/// �N���A�F�B
float4 ClearColor = { 0.6f, 0.6f, 0.6f, 0 };

/// �N���A�[�x�B
float ClearDepth = 1;

/// �Βl�B
#define POSTIBL_PI 3.1415926536f

////////////////////
// �ϐ���`�����܂�
////////////////////
// �֐���`��������
////////////////////

/// @brief ���}�b�v���T���v�����O����B
/// @param[in] ray �T���v�����O���C�����B
/// @return �T���v�����O���ʒl�B
float4 SampleEnvMap(float3 ray)
{
    float2 tuv =
        {
            atan2(ray.x, ray.z) / (POSTIBL_PI) * 0.5f + 0.5f,
            -atan2(ray.y, length(ray.xz)) / (POSTIBL_PI) + 0.5f,
        };

    return tex2D(EnvMapRTSampler, tuv);
}

/// @brief Look-up �e�N�X�`�������BRDF�����擾����B
/// @param[in] roughness ���t�l�X�l�B
/// @param[in] nvDot �@���x�N�g���Ǝ��_�x�N�g���Ƃ̓��ϒl�B
/// @return ��BRDF���B
float2 GetBrdf(float roughness, float nvDot)
{
    return tex2D(BrdfTexSampler, float2(nvDot, roughness)).rg;
}

/// @brief �e�N�X�`���𗘗p���� Hammerslay ���W�l�����߂�B
/// @param[in] index �T���v�����O�C���f�b�N�X�l�B
/// @param[in] sampleCount ���T���v�����O���B
/// @return ���W�l�B
///
/// �Q�l����: Hammersley Points on the Hemisphere
/// http://holger.dammertz.org/stuff/notes_HammersleyOnHemisphere.html
float2 CalcHammersley(uniform uint index, uniform uint sampleCount)
{
    float2 tex = { (index + 0.5f) / (POSTIBL_HAMMERSLEY_Y_SAMPLE_COUNT), 0.5f };
    return float2(float(index) / sampleCount, tex2D(HammersleyYTexSampler, tex).r);
}

/// @brief �C���|�[�^���X�T���v�����O�v�Z���s���B
/// @param[in] xi ���W�l�B
/// @param[in] r4 ���t�l�X�l��4��B
/// @param[in] normal ���K���ς݂̖@���x�N�g���l�B
/// @return �v�Z���ʂ̃x�N�g���l�B
///
/// �Q�l����: SIGGRAPH 2013 Course: Physically Based Shading in Theory and Practice
/// http://blog.selfshadow.com/publications/s2013-shading-course/
float3 CalcImportanceSampleGGX(float2 xi, float r4, float3 normal)
{
    float phi = 2 * POSTIBL_PI * xi.x;
    float cosTheta = sqrt((1 - xi.y) / (1 + (r4 - 1) * xi.y));
    float sinTheta = sqrt(1 - cosTheta * cosTheta);

    float3 upVec = (abs(normal.y) < 0.999f) ? float3(0, 1, 0) : float3(0, 0, 1);
    float3 tanX = normalize(cross(upVec, normal));
    float3 tanY = cross(normal, tanX);

    return (
        (tanX * (sinTheta * cos(phi))) +
        (tanY * (sinTheta * sin(phi))) +
        (normal * cosTheta));
}

/// @brief SSR�̃��C�g���[�X���s���B
/// @param[in] ray �P�ʃ��C�x�N�g���B
/// @param[in] roughness ���t�l�X�l�B
/// @param[in] pos �ʒu�B
/// @param[in] stepCount ���C�g���[�X�X�e�b�v�񐔁B
/// @param[in] stepOffset ���C�g���[�X�X�e�b�v�̃I�t�Z�b�g�ʁB
/// @return �g���[�X���ʂ̐F�B���l�͓K�p�x������\���B
float4 TraceSSR(
    float3 ray,
    float roughness,
    float3 pos,
    uniform int stepCount,
    uniform float stepOffset)
{
    float4 result = { 1, 1, 1, 1 };

    // SSR�K�p�x������ݒ�
    result.a *= SSRIntensity;
    result.a *= saturate(2 * (1 - roughness / SSRMaxRoughness));
    if (result.a <= 0)
    {
        return result;
    }

    // �X�N���[�����W�ł̃��C�̎n�_�ƏI�_���Z�o
    float4 rayTemp = mul(float4(pos, 1), ViewProjMatrix);
    float3 ssRayBegin = rayTemp.xyz / rayTemp.w;
    rayTemp = mul(float4(pos + ray * ScreenW, 1), ViewProjMatrix);
    float3 ssRayEnd = rayTemp.xyz / rayTemp.w;

    // �X�N���[�����W�ł̃��C�̐i�s�ʂ��Z�o
    float3 ssRayStep = (ssRayEnd - ssRayBegin) / length(ssRayEnd.xy - ssRayBegin.xy);
    ssRayStep *= 1.5f;

    // �n�_�Ɛi�s�ʂ�UVz�l���Z�o
    float3 uvzRayBegin = float3(ssRayBegin.xy * float2(0.5f, -0.5f) + 0.5f, ssRayBegin.z);
    float3 uvzRayStep = float3(ssRayStep.xy * float2(0.5f, -0.5f), ssRayStep.z);

    // �p�����[�^�p��
    float step = 1.0f / (stepCount + 1);
    float compTolerance = abs(ssRayStep.z) * step * 2;
    float minHitTime = 1;
    float lastDiff = 0;
    float sampleTime = step * (stepOffset + 1);

    // �q�b�g����
    for (int i = 0; i < stepCount; ++i, sampleTime += step)
    {
        // �T���v����UVz�l����
        float3 uvzSample = uvzRayBegin + uvzRayStep * sampleTime;

        // �[�x�l���擾
        float sampleDepth = tex2D(DepthSampler, uvzSample.xy).r;

        // �[�x�l�̍������Z�o
        float depthDiff = uvzSample.z - sampleDepth;

        // ����
        if (abs(depthDiff + compTolerance) < compTolerance)
        {
            // �q�b�g�ʒu�L�^
            float timeLerp = saturate(lastDiff / (lastDiff - depthDiff));
            float hitTime = sampleTime + timeLerp * step - step;
            minHitTime = min(minHitTime, hitTime);
        }

        // �[�x�l�̍�����ۑ�
        lastDiff = depthDiff;
    }

    // �q�b�g�ʒu�������ꍇ�͓K�p�x��������߂�
    result.a *= saturate(4 * (1 - minHitTime));

    // �q�b�gUVz�l����
    float3 uvzHit = uvzRayBegin + uvzRayStep * minHitTime;

    // ��ʒ[�͓K�p�x��������߂�
    float2 ssHit = uvzHit.xy * float2(2, -2) + float2(-1, 1);
    float2 vig = saturate(abs(ssHit) * 5 - 4);
    result.a *= saturate(1 - dot(vig, vig));

    // ���ːF���擾���ď�Z
    result *= tex2D(OrgColorRTSampler, uvzHit.xy);

    return result;
}

/// @brief SSR+IBL�F���T���v�����O����B
/// @param[in] roughness ���t�l�X�l�B
/// @param[in] pos �ʒu�B
/// @param[in] normal ���K���ς݂̖@���x�N�g���l�B
/// @param[in] eye ���K���ς݂̎��_�x�N�g���l�B
/// @param[in] sampleCount �T���v�����O�񐔁B
/// @return �T���v�����O���ʂ̐F�B
///
/// �Q�l����: SIGGRAPH 2013 Course: Physically Based Shading in Theory and Practice
/// http://blog.selfshadow.com/publications/s2013-shading-course/
float3 SampleReflectionColor(
    float roughness,
    float3 pos,
    float3 normal,
    float3 eye,
    uniform uint sampleCount)
{
    float3 color = 0;
    float weight = 0;

    float r2 = roughness * roughness;
    float r4 = r2 * r2;

    for (uint i = 0; i < sampleCount; ++i)
    {
        float2 xi = CalcHammersley(i, sampleCount);
        float3 h = CalcImportanceSampleGGX(xi, r4, normal);
        float3 ray = normalize(2 * dot(eye, h) * h - eye);

        float nrayDot = saturate(dot(normal, ray));
        if (nrayDot > 0)
        {
            // SSR�F�擾
            float4 c =
                TraceSSR(
                    ray,
                    roughness,
                    pos,
                    (POSTIBL_SSR_STEP_COUNT),
                    (POSTIBL_SSR_STEP_OFFSET));

            if (c.a < 1)
            {
                // ���}�b�v�F�ƃu�����h
                c.rgb *= c.a;
                c.rgb += SampleEnvMap(ray).rgb * (1 - c.a);
            }

            // �d�ݕt�����Z
            color.rgb += c.rgb * nrayDot;
            weight += nrayDot;
        }
    }

    return (color / max(weight, 0.001f));
}

/// @brief SSR+IBL�v�Z���s���B
/// @param[in] specular �X�y�L�����F�B
/// @param[in] roughness ���t�l�X�l�B
/// @param[in] tex �X�N���[���X�y�[�X��UV�l�B
/// @return �v�Z���ʂ̐F�B
float3 CalcReflectionColor(float3 specular, float roughness, float2 tex)
{
    // �ʒu�Ɩ@�����擾
    float3 pos = tex2D(PositionSampler, tex).xyz;
    float3 normal = normalize(tex2D(NormalSampler, tex).xyz);

    // �P�ʎ��_�x�N�g�����Z�o
    float3 eye = normalize(CameraPosition - pos);

    // SSR+IBL�F���T���v�����O
    float3 color =
        SampleReflectionColor(
            roughness,
            pos,
            normal,
            eye,
            (POSTIBL_REFLECTION_SAMPLE_COUNT));

    // BRDF�����擾
    float2 brdf = GetBrdf(roughness, saturate(dot(normal, eye)));

    // BRDF����Z
    color.rgb *= specular.rgb * brdf.x + brdf.y;

    return color;
}

////////////////////
// �֐���`��������
////////////////////
// �V�F�[�_������������
////////////////////

/// ���_�V�F�[�_�̏o�͍\���́B
struct VSOutput
{
    float4 pos : POSITION;  ///< �ʒu�B
    float2 tex : TEXCOORD0; ///< �e�N�X�`��UV�B
};

/// ���}�b�v�W�J�̒��_�V�F�[�_�������s���B
VSOutput RunEnvMapVS(float4 pos : POSITION, float2 tex : TEXCOORD0)
{
    VSOutput vsOut = (VSOutput)0;

    vsOut.pos = pos;
    vsOut.tex = tex + EnvViewportOffset;

    return vsOut;
}

/// ���}�b�v�W�J�̃s�N�Z���V�F�[�_�������s���B
float4 RunEnvMapPS(float2 tex : TEXCOORD0) : COLOR
{
    // ���}�b�v���UV�l���擾
    float2 uv = tex2D(EnvDestTexSampler, tex).rg;

    // �F���擾
    float4 color = tex2D(EnvColorSampler, uv);

    // �F��w�i�F�ƍ�����
    color.rgb = color.rgb * color.a + EnvBackColor.rgb * (1 - color.a);

    /// @todo �[�x�l���擾���ă��ɐݒ�
    color.a = 1;

    return color;
}

/// �ŏI�����_�����O�̒��_�V�F�[�_�������s���B
VSOutput RunPostIBLVS(float4 pos : POSITION, float2 tex : TEXCOORD0)
{
    VSOutput vsOut = (VSOutput)0;

    vsOut.pos = pos;
    vsOut.tex = tex + ViewportOffset;

    return vsOut;
}

/// �ŏI�����_�����O�̃s�N�Z���V�F�[�_�������s���B
float4 RunPostIBLPS(float2 tex : TEXCOORD0) : COLOR
{
#if 0
    // ���}�b�v��\�����Ă݂�B
    return tex2D(EnvColorSampler, tex);
#endif

    // ���̐F���擾
    float4 orgColor = tex2D(OrgColorRTSampler, tex);

    // �����x�[�X�}�e���A���l���擾
    float4 pbm = tex2D(MaterialSampler, tex);
    if (pbm.a <= 0)
    {
        // ���f�x������ 0 �Ȃ�Ό��̐F��Ԃ�
        return orgColor;
    }
    float metal = pbm.x;
    float rough = pbm.y;
    float specular = pbm.z;

    // �A���x�h���擾
    float4 albedo = tex2D(AlbedoSampler, tex);

    // �f�B�t���[�Y�F�ƃX�y�L�����F���Z�o
    float3 color = albedo.xyz * (1 - metal);
    float3 specColor = lerp(specular.xxx, albedo.xyz, metal);

    // SSR+IBL���ʂ����Z
    color += CalcReflectionColor(specColor, rough, tex);

    // ���̐F�ƃA���x�h�Ƃ̍������ɕ␳
    // ���̐F < �A���x�h : �e�ňÂ��Ȃ��Ă��� �� ������������Z
    // ���̐F > �A���x�h : �G�t�F�N�g���Ŕ��� �� �����ʂ����Z
    color.r = (orgColor.r < albedo.r) ? (color.r * orgColor.r / albedo.r) : (color.r + orgColor.r - albedo.r);
    color.g = (orgColor.g < albedo.g) ? (color.g * orgColor.g / albedo.g) : (color.g + orgColor.g - albedo.g);
    color.b = (orgColor.b < albedo.b) ? (color.b * orgColor.b / albedo.b) : (color.b + orgColor.b - albedo.b);

    // ���f�x������K�p
    color.rgb = lerp(orgColor.rgb, color.rgb, pbm.a);

    return float4(color, orgColor.a);
}

/// �e�N�j�b�N��`�B
technique PostIBLTec <
    string Script =
        // �ʏ�`�挋�ʂ�ۑ�
        "RenderColorTarget0=OrgColorRT;"
        "RenderDepthStencilTarget=OrgColorDS;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "ScriptExternal=Color;"

        // ���}�b�v��W�J
        "RenderColorTarget0=EnvMapRT;"
        "Pass=EnvMapPass;"

        // �ŏI�����_�����O
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "Pass=PostIBLPass;"; >
{
    pass EnvMapPass < string Script= "Draw=Buffer;"; >
    {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        ZEnable = false;
        ZWriteEnable = false;
        VertexShader = compile vs_3_0 RunEnvMapVS();
        PixelShader = compile ps_3_0 RunEnvMapPS();
    }

    pass PostIBLPass < string Script= "Draw=Buffer;"; >
    {
        ZEnable = false;
        VertexShader = compile vs_3_0 RunPostIBLVS();
        PixelShader = compile ps_3_0 RunPostIBLPS();
    }
}

////////////////////
// �V�F�[�_���������܂�
////////////////////
