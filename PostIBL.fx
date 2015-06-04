/// @file
/// @brief IBL�|�X�g�G�t�F�N�g�̃��C���t�@�C���B
/// @author ���[�`�F

// ���}�b�v�֘A��`
#include "shader/envmap_def.h"

////////////////////
// �ݒ肱������
////////////////////

/// �ʏ�`�挋�ʋL�^�p�e�N�X�`���̃t�H�[�}�b�g�B
#define POSTIBL_ORGCOLOR_RT_FORMAT "A16B16G16R16F"

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

/// �f�v�X�o�b�t�@�e�N�X�`���B
texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET < string Format = "D24S8"; >;

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

#if 0
/// ���}�b�v�e�N�X�`���B
texture2D EnvMapRT : OFFSCREENRENDERTARGET <
    string Description = "Environment map for PostIBL";
    int Width = (POSTIBL_ENVMAP_FACE_SIZE) * 4;
    int Height = (POSTIBL_ENVMAP_FACE_SIZE) * 2;
    float4 ClearColor = { 0, 0, 0, 0 };
    float ClearDepth = 1;
    string Format = POSTIBL_ENVMAP_TEX_FORMAT;
    int MipLevels = 1;
    string DefaultEffect =
        "self=hide;"
        "*=shader/EnvMapRT.fx"; >;

/// ���}�b�v�e�N�X�`���̃T���v���B
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
#endif // 0

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
    float4 ClearColor = { 0, 0, 0, 0 };
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

/// �r���[�|�[�g�T�C�Y�B
float2 ViewportSize : VIEWPORTPIXELSIZE;

/// �r���[�|�[�g�I�t�Z�b�g�B
static float2 ViewportOffset = float2(0.5f, 0.5f) / ViewportSize;

/// �N���A�F�B
float4 ClearColor = { 0.6f, 0.6f, 0.6f, 0 };

/// �N���A�[�x�B
float ClearDepth = 1;

////////////////////
// �ϐ���`�����܂�
////////////////////
// �V�F�[�_������������
////////////////////

/// ���_�V�F�[�_�̏o�͍\���́B
struct VSOutput
{
    float4 pos : POSITION;  ///< �ʒu�B
    float2 tex : TEXCOORD0; ///< �e�N�X�`��UV�B
};

/// ���_�V�F�[�_�������s���B
VSOutput RunVS(float4 pos : POSITION, float2 tex : TEXCOORD0)
{
    VSOutput vsOut = (VSOutput)0;

    vsOut.pos = pos;
    vsOut.tex = tex + ViewportOffset;

    return vsOut;
}

/// �s�N�Z���V�F�[�_�������s���B
float4 RunPS(float2 tex : TEXCOORD0) : COLOR
{
    // ���̐F���擾
    float4 orgColor = tex2D(OrgColorRTSampler, tex);

    // �����x�[�X�}�e���A���l���擾
    float4 pbm = tex2D(MaterialSampler, tex);
    if (pbm.a <= 0)
    {
        // �����x�[�X�}�e���A���l���ݒ肳��Ă��Ȃ���Ό��̐F��Ԃ�
        return orgColor;
    }
    float metal = pbm.x;
    float rough = pbm.y;
    float specular = pbm.z;

    // �A���x�h�A�ʒu�A�@���A�[�x���擾
    float4 albedo = tex2D(AlbedoSampler, tex);
    float3 pos = tex2D(PositionSampler, tex).xyz;
    float3 normal = tex2D(NormalSampler, tex).xyz;
    float depth = tex2D(DepthSampler, tex).r;

    /// @todo �ЂƂ܂��A���x�h��\�����Ă݂�B
    float4 color = lerp(orgColor, albedo, pbm.a);

    return color;
}

/// �e�N�j�b�N��`�B
technique PostIBLTec <
    string Script =
        "RenderColorTarget0=OrgColorRT;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "ScriptExternal=Color;"
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "Pass=PostIBLPass;"; >
{
    pass PostIBLPass < string Script= "Draw=Buffer;"; >
    {
        ZEnable = false;
        VertexShader = compile vs_3_0 RunVS();
        PixelShader = compile ps_3_0 RunPS();
    }
}

////////////////////
// �V�F�[�_���������܂�
////////////////////
