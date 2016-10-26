
################################################################################
# define paths
################################################################################

global env
set srcdir       $env(srcdir)
set top_srcdir   $env(top_srcdir)

set_param general.maxThreads $env(maxThreads)

global make_env
set    make_env(soc_board)        $env(SOC_BOARD)
set    make_env(VIVADO_VERSION)   $env(VIVADO_VERSION)
set    make_env(VIVADO_SOC_PART)  $env(VIVADO_SOC_PART)
set    make_env(srcdir)           $env(srcdir)
set    make_env(top_srcdir)       $env(top_srcdir)
set    make_env(maxThreads)       $env(maxThreads)
set    make_env(fpga_dir)         $env(FPGA_DIR)
set    make_env(ip_repo)          $env(FPGA_REPO_DIR)
