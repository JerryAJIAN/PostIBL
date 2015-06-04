/// @file
/// @brief �I�t�X�N���[���ɕ����x�[�X�}�e���A���l�������o�����߂̃G�t�F�N�g�B
/// @author ���[�`�F
///
/// ���O�ɉ��L�̃p�����[�^���}�N����`���邱�Ƃŏ����o���l���ς��B
///
/// POSTIBL_PBM_METALLIC  -- ���^���b�N�l�B����`���� 0.0f �B
/// POSTIBL_PBM_ROUGHNESS -- ���t�l�X�l�B����`���� 1.0f �B
/// POSTIBL_PBM_SPECULAR  -- �X�y�L�����l�B����`���� 0.04f �B
/// POSTIBL_PBM_RATIO     -- ���f�x�����B����`���� 1.0f �B

////////////////////
// �}�N����`��������
////////////////////

// ���^���b�N�l�B
#ifndef POSTIBL_PBM_METALLIC
#define POSTIBL_PBM_METALLIC 0.0f
#endif // POSTIBL_PBM_METALLIC

// ���t�l�X�l�B
#ifndef POSTIBL_PBM_ROUGHNESS
#define POSTIBL_PBM_ROUGHNESS 1.0f
#endif // POSTIBL_PBM_ROUGHNESS

// �X�y�L�����l�B
#ifndef POSTIBL_PBM_SPECULAR
#define POSTIBL_PBM_SPECULAR 0.04f
#endif // POSTIBL_PBM_SPECULAR

// ���f�x�����B
#ifndef POSTIBL_PBM_RATIO
#define POSTIBL_PBM_RATIO 1.0f
#endif // POSTIBL_PBM_RATIO

////////////////////
// �}�N����`�����܂�
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
    float4 pos : POSITION;  ///< �ʒu�B
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
float4 RunPS() : COLOR
{
    // �����x�[�X�}�e���A���l���i�[���ĕԂ�
    return
        float4(
            POSTIBL_PBM_METALLIC,
            POSTIBL_PBM_ROUGHNESS,
            POSTIBL_PBM_SPECULAR,
            POSTIBL_PBM_RATIO);
}

/// �I�u�W�F�N�g�`��e�N�j�b�N��`�B
technique ObjectTec < string MMDPass = "object"; >
{
    pass ObjectPass
    {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
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
        AlphaTestEnable = false;
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
