/// @file
/// @brief �I�t�X�N���[���ɖ@���������o�����߂̃G�t�F�N�g�B
/// @author ���[�`�F

////////////////////
// �ϐ���`��������
////////////////////

/// ���[���h�r���[�v���W�F�N�V�����}�g���N�X�B
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;

/// ���[���h�}�g���N�X�B
float4x4 WorldMatrix : WORLD;

#ifdef MIKUMIKUMOVING

/// ���[���h�r���[�}�g���N�X�B
float4x4 WorldViewMatrix : WORLDVIEW;

/// �v���W�F�N�V�����}�g���N�X�B
float4x4 ProjMatrix : PROJECTION;

/// ���[���h��ԏ�̃J�����ʒu�B
float3 CameraPosition : POSITION < string Object = "Camera"; >;

#endif // MIKUMIKUMOVING

////////////////////
// �ϐ���`�����܂�
////////////////////
// �V�F�[�_������������
////////////////////

/// ���_�V�F�[�_�̏o�͍\���́B
struct VSOutput
{
    float4 pos : POSITION;      ///< �ʒu�B
    float3 normal : TEXCOORD0;  ///< �@���B
};

/// ���_�V�F�[�_�������s���B
#ifdef MIKUMIKUMOVING
VSOutput RunVS(MMM_SKINNING_INPUT mmmIn)
#else // MIKUMIKUMOVING
VSOutput RunVS(float4 pos : POSITION, float3 normal : NORMAL)
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
#endif // MIKUMIKUMOVING

    vsOut.normal = normalize(mul(normal, (float3x3)WorldMatrix));

    float4x4 wvp = WorldViewProjMatrix;

#ifdef MIKUMIKUMOVING
    if (MMM_IsDinamicProjection)
    {
        float3 eye = CameraPosition - mul(pos, WorldMatrix).xyz;
        wvp = mul(WorldViewMatrix, MMM_DynamicFov(ProjMatrix, length(eye)));
    }
#endif // MIKUMIKUMOVING

    vsOut.pos = mul(pos, wvp);

    return vsOut;
}

/// �s�N�Z���V�F�[�_�������s���B
float4 RunPS(float3 normal : TEXCOORD0) : COLOR
{
    // �@�������̂܂܊i�[���ĕԂ�
    return float4(normalize(normal), 1);
}

/// �I�u�W�F�N�g�`��e�N�j�b�N��`�B
technique ObjectTec < string MMDPass = "object"; >
{
    pass ObjectPass
    {
        AlphaBlendEnable = false;
        VertexShader = compile vs_3_0 RunVS();
        PixelShader = compile ps_3_0 RunPS();
    }
}

/// �Z���t�V���h�E�t���I�u�W�F�N�g�`��e�N�j�b�N��`�B
technique ObjectSSTec < string MMDPass = "object_ss"; >
{
    pass ObjectSSPass
    {
        AlphaBlendEnable = false;
        VertexShader = compile vs_3_0 RunVS();
        PixelShader = compile ps_3_0 RunPS();
    }
}

// �֊s���͕`�悵�Ȃ�
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZPlotTec < string MMDPass = "zplot"; > { }

////////////////////
// �V�F�[�_���������܂�
////////////////////
