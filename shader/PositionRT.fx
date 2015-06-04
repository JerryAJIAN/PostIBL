/// @file
/// @brief �I�t�X�N���[���Ɉʒu�������o�����߂̃G�t�F�N�g�B
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
    float3 wpos : TEXCOORD0;    ///< ���[���h��ԏ�̈ʒu�B
};

/// ���_�V�F�[�_�������s���B
#ifdef MIKUMIKUMOVING
VSOutput RunVS(MMM_SKINNING_INPUT mmmIn)
#else // MIKUMIKUMOVING
VSOutput RunVS(float4 pos : POSITION)
#endif // MIKUMIKUMOVING
{
    VSOutput vsOut = (VSOutput)0;

#ifdef MIKUMIKUMOVING
    float4 pos =
        MMM_SkinnedPosition(
            mmmIn.Pos,
            mmmIn.BlendWeight,
            mmmIn.BlendIndices,
            mmmIn.SdefC,
            mmmIn.SdefR0,
            mmmIn.SdefR1);
#endif // MIKUMIKUMOVING

    vsOut.wpos = mul(pos, WorldMatrix).xyz;

    float4x4 wvp = WorldViewProjMatrix;

#ifdef MIKUMIKUMOVING
    if (MMM_IsDinamicProjection)
    {
        float3 eye = CameraPosition - vsOut.wpos;
        wvp = mul(WorldViewMatrix, MMM_DynamicFov(ProjMatrix, length(eye)));
    }
#endif // MIKUMIKUMOVING

    vsOut.pos = mul(pos, wvp);

    return vsOut;
}

/// �s�N�Z���V�F�[�_�������s���B
float4 RunPS(float3 wpos : TEXCOORD0) : COLOR
{
    // �ʒu�����̂܂܊i�[���ĕԂ�
    return float4(wpos, 1);
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
