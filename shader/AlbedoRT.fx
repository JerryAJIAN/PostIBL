/// @file
/// @brief �I�t�X�N���[���ɃA���x�h�l�������o�����߂̃G�t�F�N�g�B
/// @author ���[�`�F

////////////////////
// �ϐ���`��������
////////////////////

/// ���[���h�r���[�v���W�F�N�V�����}�g���N�X�B
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;

/// ���[���h�r���[�}�g���N�X�B
float4x4 WorldViewMatrix : WORLDVIEW;

#ifdef MIKUMIKUMOVING

/// ���[���h�}�g���N�X�B
float4x4 WorldMatrix : WORLD;

/// �v���W�F�N�V�����}�g���N�X�B
float4x4 ProjMatrix : PROJECTION;

/// ���[���h��ԏ�̃J�����ʒu�B
float3 CameraPosition : POSITION < string Object = "Camera"; >;

#else // MIKUMIKUMOVING

/// �T�u�e�N�X�`���g�p�t���O�B
bool use_subtexture;

#endif // MIKUMIKUMOVING

// �}�e���A���F
float4 MaterialDiffuse : DIFFUSE < string Object = "Geometry"; >;
float3 MaterialAmbient : AMBIENT < string Object = "Geometry"; >;
float3 MaterialEmmisive : EMISSIVE < string Object = "Geometry"; >;

// ���C�g�F
float3 LightDiffuse : DIFFUSE < string Object = "Light"; >;
float3 LightAmbient : AMBIENT < string Object = "Light"; >;

// ���Z�F
static float4 DiffuseColor = MaterialDiffuse * float4(LightDiffuse, 1);
static float3 AmbientColor = MaterialAmbient * LightAmbient + MaterialEmmisive;

// �e�N�X�`���ގ����[�t
float4 TextureAddValue : ADDINGTEXTURE;
float4 TextureMulValue : MULTIPLYINGTEXTURE;
float4 SphereAddValue : ADDINGSPHERETEXTURE;
float4 SphereMulValue : MULTIPLYINGSPHERETEXTURE;

/// �X�t�B�A�}�b�v���Z�����t���O�B
bool spadd;

/// �I�u�W�F�N�g�e�N�X�`���B
texture ObjectTex : MATERIALTEXTURE;

/// �I�u�W�F�N�g�e�N�X�`���̃T���v���B
sampler ObjectTexSampler =
    sampler_state
    {
        Texture = <ObjectTex>;
        MinFilter = LINEAR;
        MagFilter = LINEAR;
        MipFilter = LINEAR;
        AddressU = WRAP;
        AddressV = WRAP;
    };

/// �X�t�B�A�}�b�v�e�N�X�`���B
texture SphereTex : MATERIALSPHEREMAP;

/// �X�t�B�A�}�b�v�e�N�X�`���̃T���v���B
sampler SphereTexSampler =
    sampler_state
    {
        Texture = <SphereTex>;
        MinFilter = LINEAR;
        MagFilter = LINEAR;
        MipFilter = LINEAR;
        AddressU = WRAP;
        AddressV = WRAP;
    };

////////////////////
// �ϐ���`�����܂�
////////////////////
// �V�F�[�_������������
////////////////////

/// ���_�V�F�[�_�̏o�͍\���́B
struct VSOutput
{
    float4 pos : POSITION;      ///< �ʒu�B
    float2 tex : TEXCOORD0;     ///< �e�N�X�`�����W�B
    float2 spTex : TEXCOORD1;   ///< �X�t�B�A�}�b�v�e�N�X�`�����W�B
    float4 color : COLOR0;      ///< �J���[�l�B
};

/// ���_�V�F�[�_�������s���B
#ifdef MIKUMIKUMOVING
VSOutput RunVS(
    MMM_SKINNING_INPUT mmmIn,
    uniform bool useTexture,
    uniform bool useSphereMap,
    uniform bool useToon)
#else // MIKUMIKUMOVING
VSOutput RunVS(
    float4 pos : POSITION,
    float3 normal : NORMAL,
    float2 tex : TEXCOORD0,
    float2 subTex : TEXCOORD1,
    uniform bool useTexture,
    uniform bool useSphereMap,
    uniform bool useToon)
#endif // MIKUMIKUMOVING
{
    VSOutput vsOut = (VSOutput)0;

#ifdef MIKUMIKUMOVING
    MMM_SKINNING_OUTPUT skinOut =
        MMM_SkinnedPositionNormal(
            mmmIn.Pos,
            mmmIn.Normal,
            mmmIn.BlendWeight,
            mmmIn.BlendIndices,
            mmmIn.SdefC,
            mmmIn.SdefR0,
            mmmIn.SdefR1);
    float4 pos = skinOut.Position;
    float3 normal = skinOut.Normal;
    float2 tex = mmmIn.Tex;
#endif // MIKUMIKUMOVING

    // �ʒu
    float4x4 wvp = WorldViewProjMatrix;
#ifdef MIKUMIKUMOVING
    if (MMM_IsDinamicProjection)
    {
        float3 eye = CameraPosition -  mul(pos, WorldMatrix).xyz;
        wvp = mul(WorldViewMatrix, MMM_DynamicFov(ProjMatrix, length(eye)));
    }
#endif // MIKUMIKUMOVING
    vsOut.pos = mul(pos, wvp);

    // �e�N�X�`�����W
    vsOut.tex = tex;

    // �X�t�B�A�}�b�v�e�N�X�`�����W
    if (useSphereMap)
    {
#ifndef MIKUMIKUMOVING
        if (use_subtexture)
        {
            vsOut.spTex = subTex;
        }
        else
#endif // MIKUMIKUMOVING
        {
            float3 wvNormal = mul(normal, (float3x3)WorldViewMatrix);
            vsOut.spTex.x = wvNormal.x * 0.5f + 0.5f;
            vsOut.spTex.y = wvNormal.y * -0.5f + 0.5f;
        }
    }

    // �J���[�l
    vsOut.color = DiffuseColor;
#ifndef MIKUMIKUMOVING
    if (useToon)
    {
        vsOut.color.rgb = float3(0, 0, 0);
    }
#endif // MIKUMIKUMOVING
    vsOut.color.rgb += AmbientColor.rgb;
    vsOut.color = saturate(vsOut.color);

    return vsOut;
}

/// �s�N�Z���V�F�[�_�������s���B
float4 RunPS(
    VSOutput psIn,
    uniform bool useTexture,
    uniform bool useSphereMap,
    uniform bool useToon) : COLOR
{
    float4 color = psIn.color;

    // �e�N�X�`���K�p
    if (useTexture)
    {
        float4 texColor = tex2D(ObjectTexSampler, psIn.tex);

        texColor.rgb = texColor.rgb * TextureMulValue.rgb + TextureAddValue.rgb;
        float texRate = TextureMulValue.a + TextureAddValue.a;

        color.rgb *= lerp(float3(1, 1, 1), texColor.rgb, texRate);
        color.a *= texColor.a;
    }

    // �X�t�B�A�}�b�v�K�p
    if (useSphereMap)
    {
        float4 spColor = tex2D(SphereTexSampler, psIn.spTex);

        spColor.rgb = spColor.rgb * SphereMulValue.rgb + SphereAddValue.rgb;
        float spRate = SphereMulValue.a + SphereAddValue.a;

        if (spadd)
        {
            color.rgb += lerp(float3(0, 0, 0), spColor.rgb, spRate);
        }
        else
        {
            color.rgb *= lerp(float3(1, 1, 1), spColor.rgb, spRate);
        }
        color.a *= spColor.a;
    }

    return color;
}

/// �I�u�W�F�N�g�`��e�N�j�b�N��`�p�}�N���B
#define POSTIBL_OBJECT_TEC_DEF(mmdp,use_tex,use_sph,use_toon) \
    technique ObjectTec_##mmdp##use_tex##use_sph##use_toon < \
        string MMDPass = #mmdp; \
        bool UseTexture = use_tex; \
        bool UseSphereMap = use_sph; \
        bool UseToon = use_toon; > \
    { \
        pass ObjectPass \
        { \
            VertexShader = compile vs_3_0 RunVS(use_tex, use_sph, use_toon); \
            PixelShader = compile ps_3_0 RunPS(use_tex, use_sph, use_toon); } }

// �I�u�W�F�N�g�`��e�N�j�b�N�Q��`
POSTIBL_OBJECT_TEC_DEF(object,    false, false, false)
POSTIBL_OBJECT_TEC_DEF(object,     true, false, false)
POSTIBL_OBJECT_TEC_DEF(object,    false,  true, false)
POSTIBL_OBJECT_TEC_DEF(object,     true,  true, false)
POSTIBL_OBJECT_TEC_DEF(object,    false, false,  true)
POSTIBL_OBJECT_TEC_DEF(object,     true, false,  true)
POSTIBL_OBJECT_TEC_DEF(object,    false,  true,  true)
POSTIBL_OBJECT_TEC_DEF(object,     true,  true,  true)
POSTIBL_OBJECT_TEC_DEF(object_ss, false, false, false)
POSTIBL_OBJECT_TEC_DEF(object_ss,  true, false, false)
POSTIBL_OBJECT_TEC_DEF(object_ss, false,  true, false)
POSTIBL_OBJECT_TEC_DEF(object_ss,  true,  true, false)
POSTIBL_OBJECT_TEC_DEF(object_ss, false, false,  true)
POSTIBL_OBJECT_TEC_DEF(object_ss,  true, false,  true)
POSTIBL_OBJECT_TEC_DEF(object_ss, false,  true,  true)
POSTIBL_OBJECT_TEC_DEF(object_ss,  true,  true,  true)

// �֊s���͕`�悵�Ȃ�
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZPlotTec < string MMDPass = "zplot"; > { }

////////////////////
// �V�F�[�_���������܂�
////////////////////
