#----------------------------------------------------------------------------
# Makefile for cpmd.x (plane wave electronic calculation)
# Configuration: IFORT-AMD64-MPI
# Creation of Makefile: Jun 28 2010
# on Linux tmgt-10-0.local 2.6.18-164.6.1.el5 #1 SMP Tue Nov 3 16:12:36 EST 2009 x86_64 x86_64 x86_64 GNU/Linux
# Author: jpg
#----------------------------------------------------------------------------
#
SHELL = /bin/sh
#
#--------------- Default Configuration for IFORT-AMD64-MPI ---------------
SRC  = .
DEST = .
BIN  = .
FFLAGS = -pc64  -O2 -unroll 
LFLAGS =  -L.  -LROLL_MATHPATH -lmkl_solver_lp64_sequential -Wl,--start-group -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -Wl,--end-group -lpthread
CFLAGS = -O2 -Wall -m64
CPP = /lib/cpp -P -C -traditional
CPPFLAGS = -D__Linux -D__PGI -DFFT_DEFAULT -DPOINTER8 -DLINUX_IFC \
	-DPARALLEL -DMYRINET  
NOOPT_FLAG = 
CC = mpicc
FC = mpif77 -c 
LD = mpif77 -i-static 
AR = ar
#----------------------------------------------------------------------------
# Personal Configuration
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# End of Personal Configuration
#----------------------------------------------------------------------------
CFGDEST = .
CFGMACH = IFORT-AMD64-MPI
CFGQMMM = 
#
#  LIST OF FILES
#
OBJECTS = $(OBJ_AL) $(OBJ_WF) $(OBJ_GM) $(OBJ_MD) $(OBJ_MT) \
          $(OBJ_KS) $(OBJ_VA) $(OBJ_PP) $(OBJ_VD) $(OBJ_NC) \
          $(OBJ_PA) $(OBJ_IS) $(OBJ_ST) $(OBJ_SY) $(OBJ_AT) \
          $(OBJ_LA) $(OBJ_KP) $(OBJ_PI) $(OBJ_PM) $(OBJ_CL) \
          $(OBJ_PE) $(OBJ_KD) $(OBJ_MM) $(OBJ_VW) $(OBJ_BS) \
          $(OBJ_SH) $(INTERFACE_OBJECTS)
OBJ_AL  = softex.o envir.o setcnst.o azzero.o control.o \
          control_def.o control_pri.o control_bcast.o control_test.o \
          header.o inscan.o memory.o freem.o readsr.o timer.o \
          ttimp.o timec.o stopgm.o util.o dftin.o sysin.o ratom.o \
          recpnew.o recpupf.o ghermit.o detsp.o coninp.o prmem.o setsys.o \
          genxc.o setsc.o numpw.o cry.o latgen.o recips.o \
          functionals.o lsd_func.o saop.o rinit.o rinforce.o \
          rggen.o formf.o rnlset.o ylmr.o glopar.o rnlin.o \
          radin.o bessm.o ylmr2.o pbc.o ortho.o finalp.o forcep.o \
          rhopri.o phfac.o wrener.o rrane.o ranp.o rinitwf.o \
          wrgeo.o rnlsm1.o rnlsm2.o forces.o lowdin.o \
          rgs.o rgsvan.o atomwf.o atrho.o xcener.o graden.o gcener.o \
          hesele.o noforce.o rhoofr.o vpsi.o nlforce.o rotate.o \
          hnlmat.o ovlap.o dotp.o fnonloc.o gsize.o csize.o rscpot.o \
          csmat.o ksmat.o vofrho.o vofrhoa.o vofrhob.o vofrhoh.o \
          vofrhot.o vofrhoc.o initclust.o jacobi.o rnlrh.o rnlfor.o \
          potfor.o ppener.o reigs.o geofile.o rpiiint.o eicalc.o testex.o \
          densto.o proja.o atoms.o fitpack.o wv30.o rv30.o wr30wfn.o \
          setbasis.o nfunc.o gcxctbl.o hfx.o debfor.o \
          rhoofr_c.o jacobi_c.o velocitinp.o setirec.o compress.o interp3d.o \
          ptheory.o clinbcg.o elstpo.o exterp.o mulliken.o espchg.o \
          atomc.o eextern.o interpt.o egointer.o fileopen.o scratch.o \
          forcedr.o initrun.o ldos.o fnlalloc.o dqgalloc.o anneal.o \
          rnlsm.o vofrhos.o get_addr.o teststore.o loadse.o rnlsmd.o \
          wfnio.o density_functionals.o sort.o wrintf.o fftnew.o \
          fftmain.o fftutil.o fftchk.o fftprp.o fft3d.o mltfft.o gfft.o \
          gfftmain.o esslfft.o x1fft.o hpfft.o ympfft.o t3dfft.o scslfft.o fftwfft.o \
          densrd.o eam_pot.o tauofr.o vtaupsi.o metafun.o ainitwf.o dginit.o \
          kin_energy.o vpsi_lse.o disortho.o linalg.o norhoe.o ssic.o
#WaveFunctions optimization
OBJ_WF  = wfopts.o rwfopt.o updwf.o odiis.o pcgrad.o \
           k_updwf.o k_odiis.o k_forces.o k_hesele.o k_pcgrad.o \
           k_diis_rhofix.o
#GeoMetry optimisation 
OBJ_GM  = gmopts.o rgmopt.o fstart.o struc.o empfor.o puttau.o constr.o \
          rrfo.o rbfgs.o rgdiis.o sdion.o hessin.o hessout.o hessup.o \
          dum2.o detdof.o cnstfc.o fixcom.o cnstpr.o moverho.o \
          elf.o lsd_elf.o rlbfgs.o rprfo.o adapttol.o
#MeTadynamics
OBJ_MT  = meta_hpot.o meta_dyn_def.o meta_colvar.o meta_colvar_inp.o \
          meta_colvar_util.o meta_exlagr.o meta_exlagr_util.o meta_cv.o \
          meta_cv_qmmm.o tst2min.o tst2min_inp.o chain_dr.o meta_cell.o \
          meta_exl_mult.o meta_ex_mul_util.o meta_localizespin.o
#Molecular Dynamics
OBJ_MD  = mdpt.o mdmain.o dynit.o shake.o rattle.o resetac.o dispp.o nosalloc.o \
          noseinit.o nospinit.o noseng.o nosepa.o noseup.o enosmove.o pnosmove.o \
          ekinpp.o freqs.o printave.o printp.o rekine.o rinvel.o rscvp.o \
          rscve.o deort.o quenbo.o velupa.o velupi.o vepsup.o posupa.o posupi.o rortog.o \
          rortv.o crotwf.o noscinit.o prpcnosmove.o prpcmove.o prpnosmove.o \
          prcnosmove.o ddipo.o kddipo.o opeigr.o opeigr_c.o sample.o sd_wannier.o \
          wannier_center.o wannier_print.o purge.o wc_dos.o comvel.o rotvel.o \
          printfor.o cplngs.o
#Kohn-Sham energies
OBJ_KS  = davidson.o ksdiag.o vgsortho.o hpsi.o spsi.o \
          gsortho.o rhov1.o
#Vibrational Analysis
OBJ_VA  = secdpt.o secder.o sdlinres.o sd_ii.o sd_loc2.o sd_nl2.o rnlsm_2d.o \
          nl_res.o sd_loc.o sd_nl.o rho1ofr.o v1ofrho1.o lr_force.o \
          opt_lr.o lr_upd.o dd_xc.o eind_ii.o eind_loc.o eind_nl.o lr_in.o \
          lr_xcpot.o lr_ortho.o lr_pcg.o canon.o lr_tddft.o vibana.o \
          dd_xc_ana.o dd_functionals.o
#ProPerties calculations
OBJ_PP  = proppt.o prowfn.o dipo.o lodipo.o exdipo.o cmaos.o difrho.o \
          conduct.o polarise.o calc_pij.o localize.o jrotation.o \
          orbhard.o ohfd.o ohlr.o specpt.o td_dav.o td_rdiis.o td_nhdav.o lr_diag.o \
          vhk.o gettrans.o rho1pri.o rw_linres.o td_force.o tdnlfor.o \
          td_pcg.o orbrot.o  vtd2.o stcop.o afbdr.o td_os.o td_os_berry.o \
          td_prop.o g_loc_util.o wfn_print.o  znum_mat.o  \
          g_loc_spread_ide.o g_loc_exp_ide.o g_loc_optim.o \
          u_upd_spread.o  u_upd_exp.o g_loc_dr.o g_loc_exp_sum.o \
          u_upd_exp_sum.o g_loc_spread_sum.o u_upd_spread_sum.o \
          g_loc_realspace.o g_loc_xyzmat.o g_loc_opeigr.o efield.o molorb.o \
          molstates.o epr_efg.o core_spect.o potmed.o\
          nuclear_p.o rwfopt_nuc.o rinforce_nuc.o write_pp.o
#PErturbation theory
OBJ_PE  = h0psi1_p.o v1ofrho_p.o fnonloc_p.o \
          mddiag-interaction_p.o gndstate_p.o legendre_p.o \
          interaction_p.o interaction_manno_p.o \
          rotate_my_wannier_manno_p.o rotate_my_wannier_para_p.o simple_model_p.o \
          hess_eta_p.o inr_dr.o lanc_phon_p.o \
          v1xc_p.o hesele_p.o do_perturbation_p.o zdiis.o \
          pcgrad_p.o odiis_p.o rnlsm_p.o vpsi_p.o perturbation_p.o \
          eigensystem_p.o phonons_p.o rwfopt_p.o d_mat_p.o \
          updwf_p.o forces_p.o rhoofr_p.o raman_p.o opeigr_p.o \
          nmr_p.o nmr_util_p.o nmr_chi_p.o nmr_shift_p.o nmr_current_p.o \
          nmr_para_p.o nmr_full_p.o nmr_position_p.o util_p.o \
          hardness_p.o respin_p.o response_p.o restart_p.o \
          pert_kpoint_p.o dnlpdk_p.o rnl_dk_p.o \
          kpert_potential_p.o  up3_p.o friesner_c_p.o \
          matrix_p.o ks_ener_p.o kpert_util_p.o fukui_p.o mdfile.o \
          epr_p.o epr_current_p.o epr_util_p.o epr_hyp.o epr_dv0.o \
          epr_effpot.o
#VanDerbilt pseudopotentials
OBJ_VD  = readvan.o aainit.o vdbinit.o rhov.o qvan1.o qvan2.o \
          newd.o rnlfl.o augchg.o
#Non-linear Core correction
OBJ_NC  = nlccset.o copot.o corec.o cofor.o nlccstr.o
#PArallel work
OBJ_PA  = startpa.o loadpa.o sumfnl.o glosum.o summat.o my_para.o \
          glomax.o glomin.o groups.o
#ISolated system
OBJ_IS  = hipin.o hip.o mtin.o
#STress tensor calculation
OBJ_ST  = stress.o vlocst.o htrstr.o xcstr.o drhov.o \
          nlsl.o nlsm1_s.o dqvan2.o dylmr.o ffsum.o qrada_s.o \
          totstr.o putbet.o ranc.o newcell.o sdcell.o prpt.o prcpmd.o \
          npt_md.o
#SYmmetry
OBJ_SY  = symmetry.o chksym.o symtrz.o multtb.o molsym.o
#ATomic
OBJ_AT  = lsfbtr.o
#LAnczos diagonalisation
OBJ_LA  = friesner.o friesner_c.o  ehpsi.o    rrandd.o updrho.o anderson.o \
          adjmu.o    forces_diag.o mddiag.o   extrap.o bogol.o  calc_alm.o \
          vbeta.o    rhodiis.o     rwswap.o   frsblk.o frsblk_c.o \
          mixing_r.o mixing_g.o    broyden.o  dist_friesner.o  \
          dist_prowfn.o ksmat_dist.o gs_disortho.o
#KPoints
OBJ_KP  = enbandpri.o   rkpnt.o    k290.o   k290_2.o  kpclean.o
#Path Integral
OBJ_PI  = pi_cntl.o pi_init.o pi_mdpt.o pi_wf.o pi_md.o pi_diag.o \
          rreadf.o repgen.o \
          fharm.o global.o stagetrans.o pinmtrans.o getfu.o getfnm.o \
          getgyr.o getcor.o prtgyr.o evirial.o wr_temps.o
#Path Minimisation
OBJ_PM  = pm_cntl.o pm_init.o pm_wf.o pm_gmopts.o pm_mdpt.o
#KdP Theory
OBJ_KD  = kdp_diag.o kdp_prep.o kdp_rho.o kdp_stress_kin.o kdpoints.o \
          rhoofr_kdp.o
#QMMM Code 
OBJ_MM  = mm_init.o mm_dim.o mm_qmmm_forcedr.o mm_mdmain.o \
          mm_cpmd_add_MM_forces_f77.o mm_cpmd_esp_charges_f77.o \
          mm_cpmd_ext_pot_f77.o mm_mddiag.o mm_forces_diag.o \
          mm_rho_forcedr.o td_mm_qmmm_forcedr.o mm_qmmm_forcedr_bs.o  
#CLassical dynamics
OBJ_CL  = cl_init.o mdclas.o readff.o clas_force.o
#Van der Waals correction
OBJ_VW  = vdwin.o vdw.o
#Broken Symmetry
OBJ_BS = bs_forces_diag.o bswfo.o lsforce.o setbsstate.o wrccfl.o
#Surface Hopping
OBJ_SH  = mdshop_cp.o mdshop_bo.o mm_mdshop_cp.o mm_mdshop_bo.o \
          fusion.o rk4ov.o shop_adds.o sh_tddft.o
#C Code
OBJ_CC  = sysdepend.o 

#----------------------------------------------------------------------------
# LIST OF INCLUDE FILES
#----------------------------------------------------------------------------
INCFILES = system.h adat.inc atom.inc atwf.inc bc.inc   benc.inc aavan.inc \
           cell.inc cnst.inc coor.inc cotr.inc \
           cppt.inc cvan.inc dipo.inc dpot.inc elct.inc empf.inc \
           ener.inc envj.inc fileopen.inc fft.inc  func.inc geq0.inc \
           gvec.inc harm.inc head.inc ions.inc irat.inc \
           isos.inc kpnt.inc kpts.inc lodp.inc metr.inc movi.inc nlcc.inc \
           nlps.inc norm.inc nort.inc nose.inc prden.inc \
           prop.inc pslo.inc qspl.inc ragg.inc pstat.inc \
           rmas.inc ropt.inc rswf.inc sfac.inc simul.inc soft.inc \
           spin.inc str2.inc strs.inc tbxc.inc time.inc struc.inc \
           tpar.inc vdbp.inc vdbt.inc symm.inc prcp.inc poin.inc \
           memc.inc sgpp.inc filn.inc andr.inc broy.inc fint.inc \
           cray_mpp.inc ddip.inc epot.inc efld.inc efld2.inc \
           extpot.inc pimd.inc scrp.inc clas.inc store.inc atimes.inc \
           pola.inc condu.inc swap.inc ldos.inc sphe.inc fcas.inc \
           temps.inc elct2.inc symm4.inc wann.inc andp.inc response_p.inc \
           linres.inc shop.inc kdp.inc kdpc.inc conv.inc xinr.inc implhv.inc \
           mm_dim.inc mm_input.inc mm_ion_dens.inc comvel.inc vdwc.inc eam.inc \
           tpot.inc g_loc.inc cnst_dyn.inc hfx.inc dg.inc \
	   bsym.inc bsympnt.inc tauf.inc cores.inc \
           printp.inc mfep.inc \
           dir.cld gromos.h equiv_file 

#----------------------------------------------------------------------------
# OBJECTS USED IN CPMD LIBRARY
#----------------------------------------------------------------------------
OBJ_LIB = $(OBJ_CC) $(OBJECTS)
INCFILES = aavan.inc adat.inc andp.inc andr.inc atimes.inc atom.inc \
           atwf.inc bc.inc benc.inc broy.inc bsym.inc bsympnt.inc \
           cell.inc clas.inc cnst_dyn.inc cnst.inc comvel.inc condu.inc \
           conv.inc coor.inc cores.inc cotr.inc cplngs.inc cppt.inc \
           cray_mpp.inc cvan.inc ddip.inc dg.inc dipo.inc dpot.inc \
           eam.inc efld2.inc efld.inc elct2.inc elct.inc empf.inc \
           ener.inc envj.inc epot.inc extpot.inc fcas.inc fft.inc \
           fileopen.inc filn.inc fint.inc func.inc geq0.inc g_loc.inc \
           gvec.inc harm.inc head.inc hfx.inc implhv.inc ions.inc \
           irat.inc isos.inc kdpc.inc kdp.inc kpnt.inc kpts.inc \
           ksmat.inc ldos.inc linres.inc lodp.inc lscal.inc memc.inc \
           metr.inc mfep.inc mm_dim.inc mm_extrap.inc mm_input.inc mm_ion_dens.inc \
           mols.inc movi.inc nlcc.inc nlps.inc nofo.inc norm.inc \
           nort.inc nose.inc pimd.inc poin.inc pola.inc prcp.inc \
           prden.inc printp.inc prop.inc pslo.inc pstat.inc qspl.inc \
           ragg.inc read.inc response_p.inc rmas.inc ropt.inc rswf.inc \
           scrp.inc sfac.inc sgpp.inc shock.inc shop.inc simul.inc \
           soft.inc sphe.inc spin.inc store.inc str2.inc strs.inc \
           struc.inc swap.inc symm4.inc symm.inc tauf.inc tbxc.inc \
           temps.inc time.inc tpar.inc tpot.inc vdbp.inc vdbt.inc \
           vdwc.inc wann.inc xinr.inc 

EXE_OBJ=cpmd.o plotband.o
#----------------------------------------------------------------------------
# Compile cpmd.x
#----------------------------------------------------------------------------
cpmd.x : cpmd.o $(OBJECTS)   $(OBJ_CC)
	rm -f timetag.f
	$(CPP) $(CPPFLAGS) $(SRC)/timetag.F ./timetag.f
	$(FC) $(FFLAGS) ./timetag.f
	rm -f $@
	if [ "$(BIN)" != "." ]; then ln -s $(BIN)/cpmd.x cpmd.x; fi
	$(LD) -o $(BIN)/cpmd.x cpmd.o timetag.o $(OBJECTS) $(OBJ_CC)   $(LFLAGS)

#----------------------------------------------------------------------------
# Compile plotband.x
#----------------------------------------------------------------------------
plotband.x: plotband.o $(OBJECTS) $(OBJ_CC)  
	rm -f timetag.f
	$(CPP) $(CPPFLAGS) $(SRC)/timetag.F ./timetag.f
	$(FC) $(FFLAGS) ./timetag.f
	rm -f $@
	[ "$(BIN)" != "." ] && ln -s $(BIN)/$@ $@ || echo ' '
	$(LD) -o $(BIN)/$@ plotband.o timetag.o $(OBJECTS) $(OBJ_CC)   $(LFLAGS)

#----------------------------------------------------------------------------
# Generate library libcpmd.a
#----------------------------------------------------------------------------
lib : $(OBJ_LIB)
	 rm -f ./timetag.f
	 $(FC) $(FFLAGS) ./timetag.f
	 $(AR) libcpmd.a timetag.o $(OBJ_LIB)
	 $(RANLIB) libcpmd.a

#----------------------------------------------------------------------------
# Generate the manual
#----------------------------------------------------------------------------
doc : manual.ps

docpdf: manual.pdf

manual.ps: manual.dvi
	dvips -o $@ manual.dvi

manual.dvi: $(SRC)/manual.tex
	rm -f manual.aux manual.ilg manual.log manual.idx 		manual.ind  manual.out  manual.toc
	latex $(SRC)/manual.tex
	latex $(SRC)/manual.tex
	makeindex manual
	latex $(SRC)/manual.tex
	latex $(SRC)/manual.tex

manual.pdf: $(SRC)/manual.tex
	rm -f manual.aux manual.ilg manual.log manual.idx 		manual.ind  manual.out  manual.toc
	pdflatex $(SRC)/manual.tex
	pdflatex $(SRC)/manual.tex
	makeindex manual
	pdflatex $(SRC)/manual.tex
	pdflatex $(SRC)/manual.tex

#----------------------------------------------------------------------------
# Create a new makefile with new dependencies but retain the configuration.
#----------------------------------------------------------------------------
reconfig:
	( cd $(SRC) ; $(SHELL) ./mkconfig.sh $(CFGQMMM) -r -m -SRC=$(SRC) -DEST=$(CFGDEST) $(CFGMACH) ; cd $(CFGDEST) )

#----------------------------------------------------------------------------
# Remove all *.o and *.f
#----------------------------------------------------------------------------
clean : 
	rm -f $(OBJECTS) $(EXE_OBJ) $(OBJ_CC) $(OBJECTS:.o=.f) cpmd.vcg CallTree.html
	rm -f *~ .*~ *.o *.f *.L $(CHKS) $(PRJS) $(CHKS:.chk=.html)
	rm -f *.aux *.brf *.dvi *.idx *.ilg *.ind *.log $(EXE_OBJ:.o=.html)
	rm -f *.out *.ps *.pdf *.toc $(EXE_OBJ:.o=.prj) $(EXE_OBJ:.o=.chk)
	rm -f ./MM_Interface/*.f ./MM_Interface/*.o ./MM_Interface/*.L
	rm -f ./Gromos/*.f ./Gromos/*.o ./Gromos/*.L

#----------------------------------------------------------------------------
# Explicit rules
#----------------------------------------------------------------------------
.SUFFIXES:
.SUFFIXES: .o .f .F .chk

$(OBJECTS:.o=.f) $(EXE_OBJ:.o=.f): 
	rm -f $@
	$(CPP) $(CPPFLAGS) $(SRC)/$(@:.f=.F) $(DEST)/$@

$(OBJECTS) $(EXE_OBJ):
	$(FC) $(FFLAGS) $(DEST)/$< -o  $(DEST)/$@

$(OBJ_CC) :
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $(SRC)/$(@:.o=.c)


#----------------------------------------------------------------------------
# Rules for using ftnchek
#----------------------------------------------------------------------------
CHECKOPTS= -arguments=no-arrayness,no-type,number -pretty=no-parenthesis \
           -style=do-construct,distinct-do -portability=real-do,tabs -mkhtml \
	   -crossref=calls,common
PRJS=$(OBJECTS:.o=.prj) $(OBJECTS_GROMOS:.o=.prj)
CHKS=$(OBJECTS:.o=.chk) $(OBJECTS_GROMOS:.o=.chk)

check: cpmd.chk 

cpmd.chk: cpmd.f $(CHKS)
	ftnchek -calltree -include=$(SRC) $(CHECKOPTS) cpmd.f $(PRJS) > $@

.f.chk:
	ftnchek -include=$(SRC) -project $(CHECKOPTS) -usage=no-ext-undefined,no-com-\* -library $< > $@

#----------------------------------------------------------------------------
# Dependencies
#----------------------------------------------------------------------------
aainit.f:       $(SRC)/aainit.F
aainit.o:       aainit.f $(SRC)/system.h $(SRC)/aavan.inc $(SRC)/cnst.inc

adapttol.f:     $(SRC)/adapttol.F
adapttol.o:     adapttol.f $(SRC)/system.h $(SRC)/lscal.inc

adjmu.f:        $(SRC)/adjmu.F
adjmu.o:        adjmu.f $(SRC)/system.h $(SRC)/nlps.inc $(SRC)/fint.inc

afbdr.f:        $(SRC)/afbdr.F
afbdr.o:        afbdr.f $(SRC)/system.h

ainitwf.f:      $(SRC)/ainitwf.F
ainitwf.o:      ainitwf.f $(SRC)/system.h $(SRC)/ener.inc $(SRC)/geq0.inc \
                $(SRC)/ions.inc $(SRC)/pslo.inc $(SRC)/atwf.inc \
                $(SRC)/spin.inc $(SRC)/kpts.inc

anderson.f:     $(SRC)/anderson.F
anderson.o:     anderson.f $(SRC)/andr.inc

anneal.f:       $(SRC)/anneal.F
anneal.o:       anneal.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/bsym.inc \
                $(SRC)/tpar.inc $(SRC)/nose.inc $(SRC)/cnst.inc

atomc.f:        $(SRC)/atomc.F
atomc.o:        atomc.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/atwf.inc \
                $(SRC)/qspl.inc $(SRC)/cnst.inc $(SRC)/gvec.inc \
                $(SRC)/metr.inc

atoms.f:        $(SRC)/atoms.F
atoms.o:        atoms.f $(SRC)/adat.inc

atomwf.f:       $(SRC)/atomwf.F
atomwf.o:       atomwf.f $(SRC)/system.h $(SRC)/ener.inc $(SRC)/geq0.inc \
                $(SRC)/ions.inc $(SRC)/pslo.inc $(SRC)/atwf.inc \
                $(SRC)/nlps.inc $(DEST)/irat.inc $(SRC)/spin.inc \
                $(SRC)/nlcc.inc $(SRC)/kpts.inc $(SRC)/sfac.inc \
                $(SRC)/sphe.inc $(SRC)/func.inc

atrho.f:        $(SRC)/atrho.F
atrho.o:        atrho.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/spin.inc \
                $(SRC)/elct.inc $(SRC)/cnst.inc $(SRC)/geq0.inc \
                $(SRC)/pslo.inc $(SRC)/ener.inc $(SRC)/cppt.inc \
                $(SRC)/atwf.inc $(SRC)/qspl.inc $(SRC)/fft.inc \
                $(SRC)/sfac.inc $(SRC)/gvec.inc

augchg.f:       $(SRC)/augchg.F
augchg.o:       augchg.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/pslo.inc \
                $(SRC)/nlps.inc $(SRC)/cppt.inc $(SRC)/cvan.inc

azzero.f:       $(SRC)/azzero.F
azzero.o:       azzero.f

azzero_mod.f:   $(SRC)/azzero_mod.F
azzero_mod.o:   azzero_mod.f

bessm.f:        $(SRC)/bessm.F
bessm.o:        bessm.f

blas_tuned_ES.f:$(SRC)/blas_tuned_ES.F
blas_tuned_ES.o:blas_tuned_ES.f

blas_tuned_NECSX.f:$(SRC)/blas_tuned_NECSX.F
blas_tuned_NECSX.o:blas_tuned_NECSX.f

blas_tuned_SR11K.f:$(SRC)/blas_tuned_SR11K.F
blas_tuned_SR11K.o:blas_tuned_SR11K.f

blas_tuned_X1.f:$(SRC)/blas_tuned_X1.F
blas_tuned_X1.o:blas_tuned_X1.f

bogol.f:        $(SRC)/bogol.F
bogol.o:        bogol.f $(SRC)/system.h $(SRC)/kpts.inc $(SRC)/kpnt.inc \
                $(SRC)/nlps.inc $(SRC)/fint.inc $(SRC)/tauf.inc \
                $(SRC)/spin.inc

broyden.f:      $(SRC)/broyden.F
broyden.o:      broyden.f $(SRC)/geq0.inc $(SRC)/broy.inc

bs_forces_diag.f:$(SRC)/bs_forces_diag.F
bs_forces_diag.o:bs_forces_diag.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/elct.inc $(SRC)/ener.inc $(SRC)/norm.inc \
                $(SRC)/ropt.inc $(SRC)/andr.inc $(SRC)/andp.inc \
                $(SRC)/soft.inc $(SRC)/cotr.inc $(SRC)/tpar.inc \
                $(SRC)/store.inc $(SRC)/bsym.inc $(SRC)/bsympnt.inc

bswfo.f:        $(SRC)/bswfo.F
bswfo.o:        bswfo.f $(SRC)/system.h $(SRC)/bsym.inc $(SRC)/bsympnt.inc \
                $(SRC)/coor.inc $(SRC)/elct.inc $(SRC)/ener.inc \
                $(SRC)/norm.inc $(SRC)/ropt.inc $(SRC)/soft.inc \
                $(SRC)/store.inc $(SRC)/mm_dim.inc

calc_alm.f:     $(SRC)/calc_alm.F
calc_alm.o:     calc_alm.f $(SRC)/system.h $(SRC)/geq0.inc \
                $(SRC)/ions.inc $(SRC)/elct.inc $(SRC)/cppt.inc \
                $(SRC)/sfac.inc $(SRC)/nlps.inc $(SRC)/fint.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc

calc_pij.f:     $(SRC)/calc_pij.F
calc_pij.o:     calc_pij.f $(SRC)/system.h $(SRC)/cppt.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/cnst.inc \
                $(SRC)/geq0.inc

canon.f:        $(SRC)/canon.F
canon.o:        canon.f $(SRC)/system.h $(SRC)/spin.inc

chain_dr.f:     $(SRC)/chain_dr.F
chain_dr.o:     chain_dr.f $(SRC)/system.h $(SRC)/ions.inc \
                $(SRC)/cnst_dyn.inc $(SRC)/metr.inc $(SRC)/mm_input.inc \
                $(SRC)/mm_dim.inc $(DEST)/irat.inc

chksym.f:       $(SRC)/chksym.F
chksym.o:       chksym.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/symm.inc \
                $(SRC)/metr.inc $(SRC)/rmas.inc $(DEST)/irat.inc

clas_force.f:   $(SRC)/clas_force.F
clas_force.o:   clas_force.f $(SRC)/system.h $(SRC)/clas.inc \
                $(SRC)/strs.inc $(DEST)/irat.inc

clinbcg.f:      $(SRC)/clinbcg.F
clinbcg.o:      clinbcg.f $(SRC)/system.h $(SRC)/kpts.inc $(SRC)/spin.inc \
                $(SRC)/cppt.inc $(SRC)/atimes.inc $(SRC)/pslo.inc \
                $(SRC)/pola.inc

cl_init.f:      $(SRC)/cl_init.F
cl_init.o:      cl_init.f $(SRC)/system.h $(SRC)/clas.inc $(SRC)/rmas.inc \
                $(DEST)/irat.inc

cmaos.f:        $(SRC)/cmaos.F
cmaos.o:        cmaos.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/ions.inc \
                $(SRC)/atwf.inc $(SRC)/prop.inc

cnstfc.f:       $(SRC)/cnstfc.F
cnstfc.o:       cnstfc.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cotr.inc \
                $(SRC)/rmas.inc $(SRC)/tpar.inc $(SRC)/adat.inc \
                $(SRC)/ener.inc $(SRC)/isos.inc

cnstpr.f:       $(SRC)/cnstpr.F
cnstpr.o:       cnstpr.f $(SRC)/system.h $(SRC)/cotr.inc $(SRC)/mm_dim.inc

cofor.f:        $(SRC)/cofor.F
cofor.o:        cofor.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cnst.inc \
                $(SRC)/cppt.inc $(SRC)/geq0.inc $(SRC)/spin.inc \
                $(SRC)/sfac.inc $(SRC)/nlcc.inc

compress.f:     $(SRC)/compress.F
compress.o:     compress.f

comvel.f:       $(SRC)/comvel.F
comvel.o:       comvel.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/rmas.inc \
                $(SRC)/nose.inc $(SRC)/ions.inc

conduct.f:      $(SRC)/conduct.F
conduct.o:      conduct.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/cppt.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(DEST)/irat.inc \
                $(SRC)/condu.inc $(SRC)/fileopen.inc

coninp.f:       $(SRC)/coninp.F
coninp.o:       coninp.f $(SRC)/system.h $(SRC)/coor.inc $(SRC)/dpot.inc \
                $(SRC)/atom.inc $(SRC)/elct.inc $(SRC)/ions.inc \
                $(SRC)/nlps.inc $(SRC)/rmas.inc $(SRC)/cotr.inc \
                $(DEST)/irat.inc $(SRC)/mm_dim.inc $(SRC)/mm_input.inc \
                $(SRC)/fileopen.inc $(SRC)/cnst.inc

constr.f:       $(SRC)/constr.F
constr.o:       constr.f

control_bcast.f:$(SRC)/control_bcast.F
control_bcast.o:control_bcast.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/ions.inc $(SRC)/struc.inc $(SRC)/prden.inc \
                $(DEST)/irat.inc $(SRC)/benc.inc $(SRC)/nort.inc \
                $(SRC)/isos.inc $(SRC)/nose.inc $(SRC)/qspl.inc \
                $(SRC)/andr.inc $(SRC)/broy.inc $(SRC)/nlps.inc \
                $(SRC)/fint.inc $(SRC)/atwf.inc $(SRC)/store.inc \
                $(SRC)/wann.inc $(SRC)/cotr.inc $(SRC)/prop.inc \
                $(SRC)/mm_input.inc $(SRC)/xinr.inc $(SRC)/g_loc.inc \
                $(SRC)/comvel.inc $(SRC)/fileopen.inc $(SRC)/vdwc.inc

control_def.f:  $(SRC)/control_def.F
control_def.o:  control_def.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/ions.inc $(SRC)/struc.inc $(SRC)/prden.inc \
                $(DEST)/irat.inc $(SRC)/benc.inc $(SRC)/nort.inc \
                $(SRC)/isos.inc $(SRC)/nose.inc $(SRC)/qspl.inc \
                $(SRC)/andr.inc $(SRC)/broy.inc $(SRC)/nlps.inc \
                $(SRC)/fint.inc $(SRC)/atwf.inc $(SRC)/store.inc \
                $(SRC)/wann.inc $(SRC)/cotr.inc $(SRC)/kpts.inc \
                $(SRC)/prop.inc $(SRC)/conv.inc $(SRC)/xinr.inc \
                $(SRC)/g_loc.inc $(SRC)/comvel.inc $(SRC)/time.inc \
                $(SRC)/memc.inc $(SRC)/cnst_dyn.inc $(SRC)/vdwc.inc \
                $(SRC)/read.inc $(SRC)/fileopen.inc

control.f:      $(SRC)/control.F
control.o:      control.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/ions.inc \
                $(SRC)/struc.inc $(SRC)/prden.inc $(DEST)/irat.inc \
                $(SRC)/benc.inc $(SRC)/nort.inc $(SRC)/isos.inc \
                $(SRC)/nose.inc $(SRC)/qspl.inc $(SRC)/andr.inc \
                $(SRC)/broy.inc $(SRC)/nlps.inc $(SRC)/fint.inc \
                $(SRC)/atwf.inc $(SRC)/store.inc $(SRC)/wann.inc \
                $(SRC)/envj.inc $(SRC)/cotr.inc $(SRC)/kpts.inc \
                $(SRC)/prop.inc $(SRC)/shop.inc $(SRC)/mm_input.inc \
                $(SRC)/xinr.inc $(SRC)/g_loc.inc $(SRC)/lscal.inc \
                $(SRC)/comvel.inc $(SRC)/time.inc $(SRC)/memc.inc \
                $(SRC)/vdwc.inc $(SRC)/fileopen.inc

control_pri.f:  $(SRC)/control_pri.F
control_pri.o:  control_pri.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/ions.inc $(SRC)/struc.inc $(SRC)/prden.inc \
                $(DEST)/irat.inc $(SRC)/benc.inc $(SRC)/nort.inc \
                $(SRC)/isos.inc $(SRC)/nose.inc $(SRC)/qspl.inc \
                $(SRC)/andr.inc $(SRC)/broy.inc $(SRC)/nlps.inc \
                $(SRC)/fint.inc $(SRC)/atwf.inc $(SRC)/store.inc \
                $(SRC)/wann.inc $(SRC)/envj.inc $(SRC)/cotr.inc \
                $(SRC)/kpts.inc $(SRC)/shop.inc $(SRC)/xinr.inc \
                $(SRC)/lscal.inc $(SRC)/comvel.inc $(SRC)/memc.inc \
                $(SRC)/time.inc $(SRC)/fileopen.inc $(SRC)/vdwc.inc

control_test.f: $(SRC)/control_test.F
control_test.o: control_test.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/ions.inc $(SRC)/struc.inc $(SRC)/prden.inc \
                $(DEST)/irat.inc $(SRC)/benc.inc $(SRC)/nort.inc \
                $(SRC)/isos.inc $(SRC)/nose.inc $(SRC)/qspl.inc \
                $(SRC)/andr.inc $(SRC)/nlps.inc $(SRC)/fint.inc \
                $(SRC)/atwf.inc $(SRC)/store.inc $(SRC)/wann.inc \
                $(SRC)/kpts.inc $(SRC)/lscal.inc $(SRC)/broy.inc \
                $(SRC)/mm_input.inc $(SRC)/comvel.inc

copot.f:        $(SRC)/copot.F
copot.o:        copot.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/ions.inc \
                $(SRC)/elct.inc $(SRC)/cppt.inc $(SRC)/pslo.inc \
                $(SRC)/fft.inc $(SRC)/geq0.inc $(SRC)/cvan.inc \
                $(SRC)/nlcc.inc $(SRC)/kpts.inc $(SRC)/sfac.inc \
                $(SRC)/strs.inc

corec.f:        $(SRC)/corec.F
corec.o:        corec.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/ions.inc \
                $(SRC)/nlcc.inc $(SRC)/sfac.inc $(SRC)/cppt.inc \
                $(SRC)/geq0.inc $(SRC)/fft.inc

core_spect.f:   $(SRC)/core_spect.F
core_spect.o:   core_spect.f $(SRC)/system.h $(SRC)/cnst.inc \
                $(SRC)/adat.inc $(SRC)/cppt.inc $(SRC)/ions.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(DEST)/irat.inc \
                $(SRC)/atwf.inc $(SRC)/gvec.inc $(SRC)/sphe.inc \
                $(SRC)/qspl.inc $(SRC)/sfac.inc $(SRC)/cores.inc \
                $(SRC)/fileopen.inc

cplngs.f:       $(SRC)/cplngs.F
cplngs.o:       cplngs.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cplngs.inc \
                $(SRC)/spin.inc $(SRC)/ener.inc $(SRC)/kpts.inc \
                $(SRC)/andp.inc $(SRC)/lscal.inc $(SRC)/fft.inc \
                $(SRC)/coor.inc $(SRC)/cppt.inc $(SRC)/ropt.inc \
                $(SRC)/sfac.inc $(SRC)/nlps.inc $(SRC)/elct.inc \
                $(SRC)/poin.inc $(DEST)/irat.inc $(SRC)/linres.inc \
                $(SRC)/pslo.inc $(SRC)/cvan.inc $(SRC)/sgpp.inc \
                $(SRC)/cnst.inc $(SRC)/geq0.inc $(SRC)/isos.inc

cpmd.f:         $(SRC)/cpmd.F
cpmd.o:         cpmd.f $(SRC)/system.h $(SRC)/soft.inc $(SRC)/prop.inc \
                $(SRC)/poin.inc $(SRC)/pimd.inc $(SRC)/fileopen.inc \
                $(SRC)/time.inc

crotwf.f:       $(SRC)/crotwf.F
crotwf.o:       crotwf.f $(SRC)/system.h $(SRC)/spin.inc

cry.f:          $(SRC)/cry.F
cry.o:          cry.f $(SRC)/bc.inc

csize.f:        $(SRC)/csize.F
csize.o:        csize.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/kpts.inc \
                $(SRC)/spin.inc

csmat.f:        $(SRC)/csmat.F
csmat.o:        csmat.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/cvan.inc $(SRC)/nort.inc \
                $(SRC)/nlps.inc

davidson.f:     $(SRC)/davidson.F
davidson.o:     davidson.f $(SRC)/system.h $(SRC)/elct.inc \
                $(SRC)/pslo.inc $(SRC)/soft.inc $(SRC)/cppt.inc \
                $(SRC)/ions.inc $(SRC)/nlps.inc $(SRC)/cvan.inc \
                $(DEST)/irat.inc

dcopy.f:        $(SRC)/dcopy.F
dcopy.o:        dcopy.f

dd_functionals.f:$(SRC)/dd_functionals.F
dd_functionals.o:dd_functionals.f

ddipo.f:        $(SRC)/ddipo.F
ddipo.o:        ddipo.f $(SRC)/system.h $(SRC)/geq0.inc $(SRC)/ions.inc \
                $(SRC)/cnst.inc $(SRC)/ddip.inc $(SRC)/gvec.inc \
                $(DEST)/irat.inc $(SRC)/rmas.inc $(SRC)/wann.inc \
                $(SRC)/spin.inc $(SRC)/dipo.inc $(SRC)/elct.inc \
                $(SRC)/prcp.inc $(SRC)/kpts.inc $(SRC)/sphe.inc \
                $(SRC)/metr.inc

dd_xc_ana.f:    $(SRC)/dd_xc_ana.F
dd_xc_ana.o:    dd_xc_ana.f $(SRC)/system.h $(SRC)/cnst.inc \
                $(SRC)/fft.inc $(SRC)/cppt.inc

dd_xc.f:        $(SRC)/dd_xc.F
dd_xc.o:        dd_xc.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/fft.inc \
                $(SRC)/linres.inc $(SRC)/nlcc.inc $(SRC)/cppt.inc

debfor.f:       $(SRC)/debfor.F
debfor.o:       debfor.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/ener.inc \
                $(SRC)/elct.inc $(SRC)/tpar.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/soft.inc $(SRC)/norm.inc \
                $(SRC)/ropt.inc $(SRC)/cppt.inc $(SRC)/coor.inc \
                $(SRC)/sfac.inc $(SRC)/cotr.inc $(SRC)/adat.inc \
                $(SRC)/rmas.inc $(SRC)/nlcc.inc $(SRC)/symm.inc \
                $(DEST)/irat.inc $(SRC)/andr.inc $(SRC)/andp.inc \
                $(SRC)/nlps.inc $(SRC)/fint.inc $(SRC)/poin.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/store.inc \
                $(SRC)/linres.inc

density_functionals.f:$(SRC)/density_functionals.F
density_functionals.o:density_functionals.f

densrd.f:       $(SRC)/densrd.F
densrd.o:       densrd.f $(SRC)/system.h $(SRC)/cell.inc $(SRC)/gvec.inc \
                $(SRC)/ions.inc $(DEST)/irat.inc $(SRC)/response_p.inc \
                $(SRC)/fileopen.inc

densto.f:       $(SRC)/densto.F
densto.o:       densto.f $(SRC)/system.h $(SRC)/cell.inc $(SRC)/gvec.inc \
                $(SRC)/ions.inc $(DEST)/irat.inc $(SRC)/fileopen.inc \
                $(SRC)/response_p.inc $(SRC)/mm_dim.inc

deort.f:        $(SRC)/deort.F
deort.o:        deort.f

detdof.f:       $(SRC)/detdof.F
detdof.o:       detdof.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cotr.inc \
                $(SRC)/rmas.inc $(SRC)/tpar.inc $(SRC)/adat.inc \
                $(SRC)/ener.inc $(SRC)/nose.inc $(SRC)/isos.inc \
                $(SRC)/mm_input.inc $(SRC)/mm_dim.inc $(SRC)/pimd.inc

detsp.f:        $(SRC)/detsp.F
detsp.o:        detsp.f $(SRC)/system.h $(SRC)/coor.inc $(SRC)/dpot.inc \
                $(SRC)/ions.inc $(SRC)/nlps.inc $(SRC)/pslo.inc \
                $(SRC)/rmas.inc $(SRC)/ragg.inc $(SRC)/atom.inc \
                $(SRC)/vdbt.inc $(SRC)/vdbp.inc $(SRC)/nlcc.inc \
                $(DEST)/irat.inc $(SRC)/clas.inc $(SRC)/sgpp.inc \
                $(SRC)/mm_input.inc $(SRC)/cotr.inc $(SRC)/geq0.inc \
                $(SRC)/fileopen.inc

dftin.f:        $(SRC)/dftin.F
dftin.o:        dftin.f $(SRC)/system.h $(SRC)/tbxc.inc $(DEST)/irat.inc \
                $(SRC)/func.inc $(SRC)/ener.inc $(SRC)/linres.inc \
                $(SRC)/hfx.inc $(SRC)/wann.inc

dginit.f:       $(SRC)/dginit.F
dginit.o:       dginit.f $(SRC)/dg.inc

difrho.f:       $(SRC)/difrho.F
difrho.o:       difrho.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/elct.inc \
                $(SRC)/cnst.inc $(SRC)/geq0.inc $(SRC)/pslo.inc \
                $(SRC)/ener.inc $(SRC)/cppt.inc $(SRC)/fft.inc \
                $(SRC)/rswf.inc $(SRC)/ions.inc

dipo.f:         $(SRC)/dipo.F
dipo.o:         dipo.f $(SRC)/system.h $(SRC)/dipo.inc $(SRC)/geq0.inc \
                $(SRC)/ions.inc $(SRC)/cppt.inc $(SRC)/cnst.inc \
                $(SRC)/fft.inc

disortho.f:     $(SRC)/disortho.F
disortho.o:     disortho.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/ions.inc

dispp.f:        $(SRC)/dispp.F
dispp.o:        dispp.f $(SRC)/system.h $(SRC)/ions.inc

dist_friesner.f:$(SRC)/dist_friesner.F
dist_friesner.o:dist_friesner.f $(SRC)/system.h $(SRC)/nlps.inc \
                $(SRC)/fint.inc $(SRC)/geq0.inc $(DEST)/irat.inc \
                $(SRC)/kpts.inc

dist_prowfn.f:  $(SRC)/dist_prowfn.F
dist_prowfn.o:  dist_prowfn.f $(SRC)/system.h $(SRC)/atom.inc \
                $(SRC)/ener.inc $(SRC)/elct.inc $(SRC)/spin.inc \
                $(SRC)/adat.inc $(SRC)/ions.inc $(SRC)/pslo.inc \
                $(SRC)/atwf.inc $(SRC)/sfac.inc $(DEST)/irat.inc \
                $(SRC)/prop.inc $(SRC)/prden.inc $(SRC)/fileopen.inc

d_mat_p.f:      $(SRC)/d_mat_p.F
d_mat_p.o:      d_mat_p.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cnst.inc \
                $(SRC)/cppt.inc $(SRC)/geq0.inc $(SRC)/sfac.inc \
                $(SRC)/nlps.inc $(SRC)/pslo.inc $(SRC)/cvan.inc \
                $(SRC)/spin.inc $(SRC)/sgpp.inc $(SRC)/ragg.inc \
                $(SRC)/isos.inc $(SRC)/metr.inc

dnlpdk_p.f:     $(SRC)/dnlpdk_p.F
dnlpdk_p.o:     dnlpdk_p.f $(SRC)/system.h $(SRC)/ions.inc \
                $(SRC)/pslo.inc $(SRC)/nlcc.inc $(SRC)/dpot.inc \
                $(SRC)/str2.inc $(SRC)/sgpp.inc $(SRC)/nlps.inc \
                $(SRC)/fint.inc $(SRC)/response_p.inc $(SRC)/cppt.inc \
                $(SRC)/qspl.inc

do_perturbation_p.f:$(SRC)/do_perturbation_p.F
do_perturbation_p.o:do_perturbation_p.f $(SRC)/system.h $(SRC)/ions.inc \
                $(DEST)/irat.inc $(SRC)/symm.inc $(SRC)/rmas.inc \
                $(SRC)/cotr.inc $(SRC)/adat.inc $(SRC)/coor.inc \
                $(SRC)/soft.inc $(SRC)/store.inc $(SRC)/elct.inc \
                $(SRC)/spin.inc $(SRC)/sfac.inc $(SRC)/str2.inc \
                $(SRC)/nlps.inc $(SRC)/pslo.inc $(SRC)/atwf.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/fft.inc \
                $(SRC)/ropt.inc $(SRC)/isos.inc $(SRC)/mm_input.inc \
                $(SRC)/response_p.inc

dotp.f:         $(SRC)/dotp.F
dotp.o:         dotp.f $(SRC)/geq0.inc

dqgalloc.f:     $(SRC)/dqgalloc.F
dqgalloc.o:     dqgalloc.f $(SRC)/system.h $(SRC)/str2.inc \
                $(SRC)/pslo.inc $(SRC)/fft.inc $(SRC)/spin.inc

dqvan2.f:       $(SRC)/dqvan2.F
dqvan2.o:       dqvan2.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/nlps.inc \
                $(SRC)/cvan.inc $(SRC)/geq0.inc $(SRC)/qspl.inc \
                $(SRC)/cppt.inc $(SRC)/aavan.inc

drhov.f:        $(SRC)/drhov.F
drhov.o:        drhov.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/pslo.inc \
                $(SRC)/nlps.inc $(SRC)/elct.inc $(SRC)/cppt.inc \
                $(SRC)/sfac.inc $(SRC)/fft.inc $(SRC)/qspl.inc \
                $(SRC)/geq0.inc $(SRC)/strs.inc $(SRC)/str2.inc

dum2.f:         $(SRC)/dum2.F
dum2.o:         dum2.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/rmas.inc \
                $(SRC)/cotr.inc $(SRC)/mm_dim.inc

dylmr.f:        $(SRC)/dylmr.F
dylmr.o:        dylmr.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/ions.inc \
                $(SRC)/strs.inc $(SRC)/str2.inc $(SRC)/geq0.inc

dynit.f:        $(SRC)/dynit.F
dynit.o:        dynit.f $(SRC)/system.h $(SRC)/tpar.inc $(SRC)/ions.inc \
                $(SRC)/rmas.inc $(SRC)/cnst.inc $(SRC)/clas.inc

eam_pot.f:      $(SRC)/eam_pot.F
eam_pot.o:      eam_pot.f $(SRC)/system.h $(SRC)/eam.inc $(SRC)/ions.inc \
                $(SRC)/adat.inc $(SRC)/cnst.inc $(DEST)/irat.inc \
                $(SRC)/dpot.inc $(SRC)/isos.inc $(SRC)/metr.inc

eextern.f:      $(SRC)/eextern.F
eextern.o:      eextern.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cnst.inc \
                $(SRC)/cppt.inc $(SRC)/geq0.inc $(SRC)/sfac.inc \
                $(SRC)/efld.inc $(SRC)/ragg.inc $(SRC)/epot.inc \
                $(SRC)/mm_ion_dens.inc $(SRC)/mm_input.inc \
                $(SRC)/qspl.inc $(SRC)/metr.inc

efield.f:       $(SRC)/efield.F
efield.o:       efield.f $(SRC)/system.h $(DEST)/irat.inc $(SRC)/elct.inc \
                $(SRC)/ddip.inc $(SRC)/geq0.inc $(SRC)/ener.inc \
                $(SRC)/ions.inc $(SRC)/gvec.inc

egointer.f:     $(SRC)/egointer.F
egointer.o:     egointer.f $(SRC)/system.h $(SRC)/ener.inc \
                $(SRC)/elct.inc $(SRC)/tpar.inc $(SRC)/pslo.inc \
                $(SRC)/norm.inc $(SRC)/ropt.inc $(SRC)/cppt.inc \
                $(SRC)/sfac.inc $(SRC)/coor.inc $(SRC)/nlcc.inc \
                $(SRC)/ions.inc $(SRC)/epot.inc $(SRC)/efld.inc \
                $(SRC)/efld2.inc $(SRC)/spin.inc $(SRC)/store.inc \
                $(DEST)/irat.inc $(SRC)/fileopen.inc $(SRC)/cnst.inc \
                $(SRC)/prop.inc $(SRC)/dipo.inc $(SRC)/lodp.inc \
                $(SRC)/atwf.inc $(SRC)/geq0.inc $(SRC)/isos.inc \
                $(SRC)/fft.inc $(SRC)/soft.inc $(SRC)/kpts.inc

ehpsi.f:        $(SRC)/ehpsi.F
ehpsi.o:        ehpsi.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/pslo.inc \
                $(SRC)/elct.inc $(SRC)/norm.inc $(SRC)/ions.inc \
                $(SRC)/cvan.inc $(SRC)/geq0.inc $(SRC)/cppt.inc \
                $(SRC)/nlps.inc $(SRC)/fint.inc $(SRC)/coor.inc \
                $(SRC)/sfac.inc $(SRC)/fft.inc $(SRC)/kpts.inc \
                $(SRC)/spin.inc $(SRC)/kpnt.inc $(SRC)/sgpp.inc

eicalc.f:       $(SRC)/eicalc.F
eicalc.o:       eicalc.f $(SRC)/system.h $(SRC)/sfac.inc $(SRC)/ions.inc \
                $(SRC)/cppt.inc

eigensystem_p.f:$(SRC)/eigensystem_p.F
eigensystem_p.o:eigensystem_p.f $(SRC)/system.h $(SRC)/fft.inc \
                $(SRC)/coor.inc $(SRC)/adat.inc $(SRC)/ions.inc \
                $(SRC)/nlps.inc $(SRC)/cppt.inc $(SRC)/geq0.inc \
                $(SRC)/response_p.inc

eind_ii.f:      $(SRC)/eind_ii.F
eind_ii.o:      eind_ii.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cnst.inc \
                $(SRC)/ragg.inc $(SRC)/isos.inc $(SRC)/metr.inc

eind_loc.f:     $(SRC)/eind_loc.F
eind_loc.o:     eind_loc.f $(SRC)/system.h $(SRC)/ions.inc \
                $(SRC)/cnst.inc $(SRC)/cppt.inc $(SRC)/geq0.inc \
                $(SRC)/sfac.inc

eind_nl.f:      $(SRC)/eind_nl.F
eind_nl.o:      eind_nl.f $(SRC)/system.h $(SRC)/nlps.inc $(SRC)/elct.inc \
                $(SRC)/ions.inc $(SRC)/pslo.inc $(SRC)/cvan.inc \
                $(SRC)/cppt.inc $(SRC)/spin.inc $(SRC)/sgpp.inc \
                $(SRC)/sfac.inc

ekinpp.f:       $(SRC)/ekinpp.F
ekinpp.o:       ekinpp.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/rmas.inc \
                $(SRC)/pimd.inc

elec_disp.f:    $(SRC)/elec_disp.F
elec_disp.o:    elec_disp.f $(SRC)/system.h $(SRC)/geq0.inc \
                $(SRC)/ions.inc $(SRC)/cnst.inc $(SRC)/ddip.inc \
                $(SRC)/gvec.inc $(DEST)/irat.inc $(SRC)/rmas.inc

elf.f:          $(SRC)/elf.F
elf.o:          elf.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/cppt.inc \
                $(SRC)/ions.inc $(SRC)/elct.inc $(SRC)/pslo.inc \
                $(SRC)/poin.inc $(SRC)/qspl.inc $(SRC)/fft.inc \
                $(SRC)/atwf.inc $(SRC)/ener.inc $(SRC)/prden.inc \
                $(SRC)/kpts.inc $(SRC)/pimd.inc $(SRC)/bsym.inc

elstpo.f:       $(SRC)/elstpo.F
elstpo.o:       elstpo.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/cppt.inc \
                $(SRC)/geq0.inc $(SRC)/isos.inc $(SRC)/fft.inc

empfor.f:       $(SRC)/empfor.F
empfor.o:       empfor.f $(SRC)/system.h $(SRC)/empf.inc $(SRC)/cnst.inc \
                $(SRC)/adat.inc $(SRC)/ions.inc $(DEST)/irat.inc \
                $(SRC)/cotr.inc

enbandpri.f:    $(SRC)/enbandpri.F
enbandpri.o:    enbandpri.f $(SRC)/system.h $(SRC)/cnst.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/elct.inc \
                $(SRC)/fileopen.inc

enosmove.f:     $(SRC)/enosmove.F
enosmove.o:     enosmove.f $(SRC)/system.h $(SRC)/nose.inc

envir.f:        $(SRC)/envir.F
envir.o:        envir.f $(SRC)/envj.inc

epr_current_p.f:$(SRC)/epr_current_p.F
epr_current_p.o:epr_current_p.f $(SRC)/system.h $(SRC)/cppt.inc \
                $(SRC)/coor.inc $(SRC)/cnst.inc $(SRC)/spin.inc \
                $(SRC)/fft.inc $(SRC)/ions.inc $(SRC)/geq0.inc \
                $(SRC)/response_p.inc $(SRC)/prop.inc $(SRC)/elct.inc \
                $(SRC)/wann.inc

epr_dv0.f:      $(SRC)/epr_dv0.F
epr_dv0.o:      epr_dv0.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/fft.inc \
                $(SRC)/cppt.inc

epr_effpot.f:   $(SRC)/epr_effpot.F
epr_effpot.o:   epr_effpot.f $(SRC)/system.h $(SRC)/cnst.inc \
                $(SRC)/fft.inc $(SRC)/cppt.inc $(SRC)/geq0.inc \
                $(SRC)/qspl.inc $(SRC)/ions.inc $(SRC)/adat.inc \
                $(SRC)/atom.inc $(SRC)/dpot.inc $(SRC)/ragg.inc \
                $(SRC)/gvec.inc $(SRC)/response_p.inc $(SRC)/sfac.inc

epr_efg.f:      $(SRC)/epr_efg.F
epr_efg.o:      epr_efg.f $(SRC)/system.h $(SRC)/prop.inc $(SRC)/spin.inc \
                $(SRC)/ions.inc $(SRC)/cnst.inc $(SRC)/geq0.inc \
                $(SRC)/cppt.inc $(SRC)/coor.inc $(SRC)/gvec.inc \
                $(SRC)/fft.inc $(SRC)/fileopen.inc $(SRC)/sfac.inc

epr_hyp.f:      $(SRC)/epr_hyp.F
epr_hyp.o:      epr_hyp.f $(SRC)/system.h $(SRC)/response_p.inc \
                $(SRC)/prop.inc $(SRC)/cnst.inc $(SRC)/cppt.inc \
                $(SRC)/gvec.inc $(SRC)/coor.inc $(SRC)/ions.inc \
                $(SRC)/fft.inc $(SRC)/spin.inc $(SRC)/elct.inc \
                $(SRC)/atwf.inc $(SRC)/adat.inc $(SRC)/sfac.inc \
                $(SRC)/pslo.inc $(SRC)/geq0.inc

epr_p.f:        $(SRC)/epr_p.F
epr_p.o:        epr_p.f $(SRC)/system.h $(SRC)/response_p.inc \
                $(SRC)/prop.inc $(SRC)/cnst.inc $(SRC)/cppt.inc \
                $(SRC)/gvec.inc $(SRC)/ddip.inc $(SRC)/isos.inc \
                $(SRC)/wann.inc $(SRC)/coor.inc $(SRC)/ions.inc \
                $(SRC)/store.inc $(SRC)/soft.inc $(SRC)/ropt.inc \
                $(SRC)/sfac.inc $(SRC)/fft.inc $(SRC)/spin.inc \
                $(SRC)/elct.inc

epr_util_p.f:   $(SRC)/epr_util_p.F
epr_util_p.o:   epr_util_p.f $(SRC)/system.h $(SRC)/soft.inc \
                $(SRC)/response_p.inc

espchg.f:       $(SRC)/espchg.F
espchg.o:       espchg.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/adat.inc \
                $(SRC)/cnst.inc $(SRC)/sfac.inc $(SRC)/cppt.inc \
                $(SRC)/fft.inc $(SRC)/geq0.inc $(SRC)/isos.inc \
                $(SRC)/elct.inc

esslfft.f:      $(SRC)/esslfft.F
esslfft.o:      esslfft.f $(SRC)/system.h $(SRC)/fft.inc

evirial.f:      $(SRC)/evirial.F
evirial.o:      evirial.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/nose.inc \
                $(SRC)/pimd.inc $(SRC)/cnst.inc

exdipo.f:       $(SRC)/exdipo.F
exdipo.o:       exdipo.f $(SRC)/system.h $(SRC)/dipo.inc $(SRC)/lodp.inc \
                $(SRC)/ions.inc $(SRC)/cppt.inc $(SRC)/cnst.inc \
                $(SRC)/prop.inc

exterp.f:       $(SRC)/exterp.F
exterp.o:       exterp.f $(SRC)/system.h $(SRC)/extpot.inc \
                $(SRC)/efld.inc $(SRC)/isos.inc

extrap.f:       $(SRC)/extrap.F
extrap.o:       extrap.f

ffsum.f:        $(SRC)/ffsum.F
ffsum.o:        ffsum.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/ions.inc \
                $(SRC)/dpot.inc $(SRC)/ragg.inc $(SRC)/cppt.inc \
                $(SRC)/str2.inc $(SRC)/sfac.inc $(SRC)/qspl.inc \
                $(SRC)/geq0.inc

fft3d.f:        $(SRC)/fft3d.F
fft3d.o:        fft3d.f $(SRC)/system.h $(SRC)/fft.inc

fftchk.f:       $(SRC)/fftchk.F
fftchk.o:       fftchk.f

fftmain.f:      $(SRC)/fftmain.F
fftmain.o:      fftmain.f $(SRC)/system.h

fftnew.f:       $(SRC)/fftnew.F
fftnew.o:       fftnew.f $(SRC)/system.h $(SRC)/fft.inc $(SRC)/cppt.inc \
                $(SRC)/cnst.inc $(SRC)/cell.inc $(SRC)/kpts.inc \
                $(DEST)/irat.inc

fftprp.f:       $(SRC)/fftprp.F
fftprp.o:       fftprp.f $(SRC)/system.h $(SRC)/cppt.inc $(DEST)/irat.inc \
                $(SRC)/fft.inc $(SRC)/rswf.inc $(SRC)/elct.inc \
                $(SRC)/isos.inc $(SRC)/pimd.inc $(SRC)/kpnt.inc \
                $(SRC)/kpts.inc

fftutil.f:      $(SRC)/fftutil.F
fftutil.o:      fftutil.f $(SRC)/system.h $(SRC)/cppt.inc $(SRC)/fft.inc

fftwfft.f:      $(SRC)/fftwfft.F
fftwfft.o:      fftwfft.f $(SRC)/system.h $(SRC)/fft.inc

fharm.f:        $(SRC)/fharm.F
fharm.o:        fharm.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/isos.inc \
                $(SRC)/pimd.inc $(SRC)/cnst.inc

fileopen.f:     $(SRC)/fileopen.F
fileopen.o:     fileopen.f $(SRC)/fileopen.inc

finalp.f:       $(SRC)/finalp.F
finalp.o:       finalp.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/adat.inc \
                $(SRC)/cnst.inc $(SRC)/dipo.inc $(SRC)/norm.inc \
                $(SRC)/elct.inc $(SRC)/ener.inc $(SRC)/kpts.inc \
                $(SRC)/kpnt.inc $(SRC)/strs.inc $(SRC)/prcp.inc \
                $(SRC)/metr.inc $(SRC)/rmas.inc $(SRC)/ropt.inc \
                $(SRC)/store.inc

fitpack.f:      $(SRC)/fitpack.F
fitpack.o:      fitpack.f

fixcom.f:       $(SRC)/fixcom.F
fixcom.o:       fixcom.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/rmas.inc \
                $(SRC)/cotr.inc

fnlalloc.f:     $(SRC)/fnlalloc.F
fnlalloc.o:     fnlalloc.f $(SRC)/system.h $(SRC)/sfac.inc \
                $(SRC)/nlps.inc $(SRC)/ions.inc $(SRC)/shop.inc

fnonloc.f:      $(SRC)/fnonloc.F
fnonloc.o:      fnonloc.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/nlps.inc \
                $(SRC)/ions.inc $(SRC)/pslo.inc $(SRC)/cvan.inc \
                $(SRC)/sfac.inc $(SRC)/cppt.inc $(SRC)/sgpp.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/cnst.inc \
                $(SRC)/geq0.inc $(SRC)/ener.inc

fnonloc_p.f:    $(SRC)/fnonloc_p.F
fnonloc_p.o:    fnonloc_p.f $(SRC)/system.h $(SRC)/nlps.inc \
                $(SRC)/ions.inc $(SRC)/pslo.inc $(SRC)/sfac.inc \
                $(SRC)/cppt.inc $(SRC)/sgpp.inc $(SRC)/kpts.inc \
                $(SRC)/kpnt.inc $(SRC)/geq0.inc $(SRC)/response_p.inc

forcedr.f:      $(SRC)/forcedr.F
forcedr.o:      forcedr.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/pslo.inc \
                $(SRC)/cotr.inc $(SRC)/tpar.inc $(SRC)/pimd.inc \
                $(SRC)/bsym.inc $(SRC)/mm_dim.inc $(SRC)/kpts.inc

forcep.f:       $(SRC)/forcep.F
forcep.o:       forcep.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/fft.inc \
                $(SRC)/isos.inc

forces_diag.f:  $(SRC)/forces_diag.F
forces_diag.o:  forces_diag.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/elct.inc $(SRC)/ener.inc $(SRC)/norm.inc \
                $(SRC)/ropt.inc $(SRC)/andr.inc $(SRC)/andp.inc \
                $(SRC)/soft.inc $(SRC)/cotr.inc $(SRC)/tpar.inc \
                $(SRC)/store.inc $(SRC)/elct2.inc $(SRC)/kpts.inc \
                $(SRC)/mm_extrap.inc $(SRC)/pslo.inc $(SRC)/nlps.inc \
                $(SRC)/fint.inc

forces.f:       $(SRC)/forces.F
forces.o:       forces.f $(SRC)/system.h $(SRC)/norm.inc $(SRC)/pslo.inc \
                $(SRC)/ropt.inc $(SRC)/elct.inc $(SRC)/geq0.inc \
                $(SRC)/cppt.inc $(SRC)/spin.inc $(SRC)/ions.inc \
                $(SRC)/kpts.inc $(SRC)/nlps.inc $(SRC)/ener.inc \
                $(SRC)/rswf.inc $(SRC)/fft.inc

forces_p.f:     $(SRC)/forces_p.F
forces_p.o:     forces_p.f $(SRC)/system.h $(SRC)/norm.inc \
                $(SRC)/pslo.inc $(SRC)/ropt.inc $(SRC)/elct.inc \
                $(SRC)/geq0.inc $(SRC)/cppt.inc $(SRC)/spin.inc \
                $(SRC)/ions.inc $(SRC)/kpts.inc $(SRC)/nlps.inc \
                $(SRC)/response_p.inc $(SRC)/ener.inc

formf.f:        $(SRC)/formf.F
formf.o:        formf.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/atom.inc \
                $(SRC)/ions.inc $(SRC)/dpot.inc $(SRC)/ragg.inc \
                $(SRC)/cppt.inc $(SRC)/qspl.inc $(SRC)/gvec.inc \
                $(SRC)/sgpp.inc $(SRC)/pslo.inc $(SRC)/vdbp.inc

freem.f:        $(SRC)/freem.F
freem.o:        freem.f $(SRC)/system.h $(SRC)/memc.inc $(DEST)/irat.inc

freqs.f:        $(SRC)/freqs.F
freqs.o:        freqs.f $(SRC)/system.h $(SRC)/harm.inc $(SRC)/elct.inc \
                $(SRC)/nlps.inc $(SRC)/ions.inc $(SRC)/pslo.inc \
                $(SRC)/cppt.inc $(SRC)/cvan.inc $(SRC)/tpar.inc \
                $(SRC)/sgpp.inc $(SRC)/metr.inc $(SRC)/simul.inc

friesner_c.f:   $(SRC)/friesner_c.F
friesner_c.o:   friesner_c.f $(SRC)/system.h $(SRC)/nlps.inc \
                $(SRC)/fint.inc $(SRC)/geq0.inc $(DEST)/irat.inc

friesner_c_p.f: $(SRC)/friesner_c_p.F
friesner_c_p.o: friesner_c_p.f $(SRC)/system.h $(SRC)/nlps.inc \
                $(SRC)/fint.inc $(SRC)/geq0.inc $(DEST)/irat.inc

friesner.f:     $(SRC)/friesner.F
friesner.o:     friesner.f $(SRC)/system.h $(SRC)/nlps.inc \
                $(SRC)/fint.inc $(SRC)/geq0.inc $(DEST)/irat.inc \
                $(SRC)/kpts.inc

frsblk_c.f:     $(SRC)/frsblk_c.F
frsblk_c.o:     frsblk_c.f $(SRC)/system.h $(SRC)/nlps.inc \
                $(SRC)/fint.inc $(SRC)/geq0.inc $(DEST)/irat.inc \
                $(SRC)/kpts.inc

frsblk.f:       $(SRC)/frsblk.F
frsblk.o:       frsblk.f $(SRC)/system.h $(SRC)/nlps.inc $(SRC)/fint.inc \
                $(SRC)/geq0.inc $(DEST)/irat.inc $(SRC)/kpts.inc

fstart.f:       $(SRC)/fstart.F
fstart.o:       fstart.f $(SRC)/system.h $(SRC)/empf.inc $(SRC)/cnst.inc

fukui_p.f:      $(SRC)/fukui_p.F
fukui_p.o:      fukui_p.f $(SRC)/system.h $(DEST)/irat.inc \
                $(SRC)/rmas.inc $(SRC)/cnst.inc $(SRC)/gvec.inc \
                $(SRC)/geq0.inc $(SRC)/prop.inc $(SRC)/metr.inc \
                $(SRC)/cppt.inc $(SRC)/spin.inc $(SRC)/response_p.inc \
                $(SRC)/fft.inc $(SRC)/ions.inc $(SRC)/coor.inc \
                $(SRC)/adat.inc $(SRC)/elct.inc $(SRC)/kpnt.inc \
                $(SRC)/nlps.inc $(SRC)/sfac.inc

functionals.f:  $(SRC)/functionals.F
functionals.o:  functionals.f $(SRC)/func.inc

fusion.f:       $(SRC)/fusion.F
fusion.o:       fusion.f $(SRC)/system.h $(SRC)/shop.inc $(SRC)/filn.inc \
                $(SRC)/coor.inc $(SRC)/store.inc $(SRC)/elct.inc

gcener.f:       $(SRC)/gcener.F
gcener.o:       gcener.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/fft.inc \
                $(SRC)/cppt.inc $(SRC)/strs.inc $(SRC)/func.inc \
                $(SRC)/tbxc.inc $(SRC)/spin.inc $(SRC)/tauf.inc

gcxctbl.f:      $(SRC)/gcxctbl.F
gcxctbl.o:      gcxctbl.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/tbxc.inc

genxc.f:        $(SRC)/genxc.F
genxc.o:        genxc.f $(SRC)/system.h $(SRC)/tbxc.inc $(SRC)/func.inc

geofile.f:      $(SRC)/geofile.F
geofile.o:      geofile.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/metr.inc \
                $(SRC)/pimd.inc $(SRC)/adat.inc $(SRC)/cnst.inc \
                $(SRC)/fileopen.inc $(DEST)/irat.inc $(SRC)/mm_dim.inc

get_addr.f:     $(SRC)/get_addr.F
get_addr.o:     get_addr.f

getcor.f:       $(SRC)/getcor.F
getcor.o:       getcor.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/pimd.inc

getfnm.f:       $(SRC)/getfnm.F
getfnm.o:       getfnm.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/rmas.inc \
                $(SRC)/pimd.inc $(SRC)/cnst.inc

getfu.f:        $(SRC)/getfu.F
getfu.o:        getfu.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/rmas.inc \
                $(SRC)/pimd.inc $(SRC)/cnst.inc

getgyr.f:       $(SRC)/getgyr.F
getgyr.o:       getgyr.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/rmas.inc \
                $(SRC)/pimd.inc $(SRC)/cnst.inc $(SRC)/nose.inc

gettrans.f:     $(SRC)/gettrans.F
gettrans.o:     gettrans.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/linres.inc $(SRC)/cnst.inc

gfft.f:         $(SRC)/gfft.F
gfft.o:         gfft.f

gfftmain.f:     $(SRC)/gfftmain.F
gfftmain.o:     gfftmain.f $(SRC)/system.h $(SRC)/fft.inc

ghermit.f:      $(SRC)/ghermit.F
ghermit.o:      ghermit.f

global.f:       $(SRC)/global.F
global.o:       global.f $(SRC)/system.h $(SRC)/pimd.inc

g_loc_dr.f:     $(SRC)/g_loc_dr.F
g_loc_dr.o:     g_loc_dr.f $(SRC)/system.h $(SRC)/g_loc.inc \
                $(SRC)/spin.inc $(SRC)/store.inc $(SRC)/geq0.inc \
                $(SRC)/kpts.inc $(SRC)/wann.inc $(SRC)/fileopen.inc \
                $(SRC)/cnst.inc $(SRC)/kpnt.inc $(SRC)/cppt.inc \
                $(DEST)/irat.inc

g_loc_exp_ide.f:$(SRC)/g_loc_exp_ide.F
g_loc_exp_ide.o:g_loc_exp_ide.f $(SRC)/system.h $(SRC)/geq0.inc \
                $(SRC)/ions.inc $(SRC)/cnst.inc $(SRC)/ddip.inc \
                $(SRC)/gvec.inc $(DEST)/irat.inc $(SRC)/rmas.inc \
                $(SRC)/g_loc.inc $(SRC)/spin.inc $(SRC)/cppt.inc \
                $(SRC)/fileopen.inc

g_loc_exp_sum.f:$(SRC)/g_loc_exp_sum.F
g_loc_exp_sum.o:g_loc_exp_sum.f $(SRC)/system.h $(SRC)/geq0.inc \
                $(SRC)/ions.inc $(SRC)/cnst.inc $(SRC)/ddip.inc \
                $(SRC)/gvec.inc $(DEST)/irat.inc $(SRC)/rmas.inc \
                $(SRC)/g_loc.inc $(SRC)/spin.inc $(SRC)/cppt.inc \
                $(SRC)/wann.inc $(SRC)/fileopen.inc

g_loc_opeigr.f: $(SRC)/g_loc_opeigr.F
g_loc_opeigr.o: g_loc_opeigr.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/ddip.inc $(SRC)/g_loc.inc

g_loc_optim.f:  $(SRC)/g_loc_optim.F
g_loc_optim.o:  g_loc_optim.f $(SRC)/system.h $(SRC)/g_loc.inc \
                $(SRC)/wann.inc

g_loc_realspace.f:$(SRC)/g_loc_realspace.F
g_loc_realspace.o:g_loc_realspace.f $(SRC)/system.h $(SRC)/fft.inc \
                $(DEST)/irat.inc $(SRC)/cppt.inc $(SRC)/g_loc.inc \
                $(SRC)/cell.inc $(SRC)/gvec.inc $(SRC)/ions.inc \
                $(SRC)/coor.inc $(SRC)/cnst.inc $(SRC)/fileopen.inc

g_loc_spread_ide.f:$(SRC)/g_loc_spread_ide.F
g_loc_spread_ide.o:g_loc_spread_ide.f $(SRC)/system.h $(SRC)/geq0.inc \
                $(SRC)/ions.inc $(SRC)/cnst.inc $(SRC)/ddip.inc \
                $(SRC)/gvec.inc $(DEST)/irat.inc $(SRC)/rmas.inc \
                $(SRC)/g_loc.inc $(SRC)/spin.inc $(SRC)/cppt.inc \
                $(SRC)/fileopen.inc $(SRC)/metr.inc

g_loc_spread_sum.f:$(SRC)/g_loc_spread_sum.F
g_loc_spread_sum.o:g_loc_spread_sum.f $(SRC)/system.h $(SRC)/geq0.inc \
                $(SRC)/ions.inc $(SRC)/cnst.inc $(SRC)/ddip.inc \
                $(SRC)/gvec.inc $(DEST)/irat.inc $(SRC)/rmas.inc \
                $(SRC)/g_loc.inc $(SRC)/spin.inc $(SRC)/cppt.inc \
                $(SRC)/fileopen.inc

g_loc_util.f:   $(SRC)/g_loc_util.F
g_loc_util.o:   g_loc_util.f $(SRC)/g_loc.inc $(SRC)/system.h \
                $(SRC)/cppt.inc $(SRC)/geq0.inc $(SRC)/cnst.inc \
                $(SRC)/fileopen.inc

g_loc_xyzmat.f: $(SRC)/g_loc_xyzmat.F
g_loc_xyzmat.o: g_loc_xyzmat.f $(SRC)/system.h $(SRC)/geq0.inc \
                $(SRC)/cnst.inc $(SRC)/ddip.inc $(SRC)/gvec.inc \
                $(DEST)/irat.inc $(SRC)/wann.inc $(SRC)/spin.inc \
                $(SRC)/elct.inc $(SRC)/g_loc.inc

glomax.f:       $(SRC)/glomax.F
glomax.o:       glomax.f $(SRC)/system.h

glomin.f:       $(SRC)/glomin.F
glomin.o:       glomin.f $(SRC)/system.h

glopar.f:       $(SRC)/glopar.F
glopar.o:       glopar.f $(SRC)/system.h

glosum.f:       $(SRC)/glosum.F
glosum.o:       glosum.f $(SRC)/system.h $(SRC)/pimd.inc

gmopts.f:       $(SRC)/gmopts.F
gmopts.o:       gmopts.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/elct.inc \
                $(SRC)/pslo.inc $(SRC)/nlps.inc $(SRC)/atwf.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/str2.inc \
                $(SRC)/spin.inc $(SRC)/linres.inc $(SRC)/coor.inc \
                $(SRC)/bsym.inc $(SRC)/ddip.inc

gndstate_p.f:   $(SRC)/gndstate_p.F
gndstate_p.o:   gndstate_p.f $(SRC)/system.h $(SRC)/gvec.inc \
                $(DEST)/irat.inc $(SRC)/response_p.inc $(SRC)/cppt.inc \
                $(SRC)/fileopen.inc

graden.f:       $(SRC)/graden.F
graden.o:       graden.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/fft.inc \
                $(SRC)/cppt.inc

groups.f:       $(SRC)/groups.F
groups.o:       groups.f $(SRC)/system.h $(DEST)/irat.inc

gs_disortho.f:  $(SRC)/gs_disortho.F
gs_disortho.o:  gs_disortho.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/ions.inc $(SRC)/geq0.inc

gsize.f:        $(SRC)/gsize.F
gsize.o:        gsize.f $(SRC)/system.h $(SRC)/ions.inc

gsortho.f:      $(SRC)/gsortho.F
gsortho.o:      gsortho.f $(SRC)/system.h $(SRC)/geq0.inc

h0psi1_p.f:     $(SRC)/h0psi1_p.F
h0psi1_p.o:     h0psi1_p.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/pslo.inc $(SRC)/ropt.inc $(SRC)/ener.inc \
                $(SRC)/response_p.inc $(SRC)/sfac.inc $(SRC)/ions.inc \
                $(SRC)/geq0.inc $(SRC)/fft.inc

hardness_p.f:   $(SRC)/hardness_p.F
hardness_p.o:   hardness_p.f $(SRC)/system.h $(SRC)/fft.inc \
                $(SRC)/coor.inc $(SRC)/cnst.inc $(SRC)/adat.inc \
                $(SRC)/ions.inc $(SRC)/nlps.inc $(SRC)/cppt.inc \
                $(SRC)/geq0.inc $(SRC)/soft.inc $(SRC)/response_p.inc \
                $(SRC)/fileopen.inc

header.f:       $(SRC)/header.F
header.o:       header.f $(SRC)/envj.inc

hesele.f:       $(SRC)/hesele.F
hesele.o:       hesele.f $(SRC)/system.h $(SRC)/cppt.inc $(SRC)/nlps.inc \
                $(SRC)/ions.inc $(SRC)/pslo.inc $(SRC)/cvan.inc \
                $(SRC)/sgpp.inc $(SRC)/simul.inc

hesele_p.f:     $(SRC)/hesele_p.F
hesele_p.o:     hesele_p.f $(SRC)/system.h $(SRC)/cppt.inc \
                $(SRC)/nlps.inc $(SRC)/ions.inc $(SRC)/pslo.inc \
                $(SRC)/cvan.inc $(SRC)/sgpp.inc $(SRC)/simul.inc \
                $(SRC)/elct.inc $(SRC)/response_p.inc

hess_eta_p.f:   $(SRC)/hess_eta_p.F
hess_eta_p.o:   hess_eta_p.f $(SRC)/system.h $(SRC)/ions.inc \
                $(DEST)/irat.inc $(SRC)/symm.inc $(SRC)/rmas.inc \
                $(SRC)/cotr.inc $(SRC)/adat.inc $(SRC)/coor.inc \
                $(SRC)/soft.inc $(SRC)/store.inc $(SRC)/elct.inc \
                $(SRC)/spin.inc $(SRC)/sfac.inc $(SRC)/nlps.inc \
                $(SRC)/pslo.inc $(SRC)/atwf.inc $(SRC)/kpts.inc \
                $(SRC)/kpnt.inc $(SRC)/fft.inc $(SRC)/response_p.inc \
                $(SRC)/prop.inc $(SRC)/implhv.inc

hessin.f:       $(SRC)/hessin.F
hessin.o:       hessin.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cotr.inc \
                $(SRC)/fileopen.inc

hessout.f:      $(SRC)/hessout.F
hessout.o:      hessout.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cotr.inc \
                $(SRC)/fileopen.inc

hessup.f:       $(SRC)/hessup.F
hessup.o:       hessup.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cotr.inc

hfx.f:          $(SRC)/hfx.F
hfx.o:          hfx.f $(SRC)/system.h $(SRC)/ener.inc $(SRC)/cppt.inc \
                $(SRC)/geq0.inc $(SRC)/spin.inc $(SRC)/fft.inc \
                $(SRC)/pslo.inc $(SRC)/kpts.inc $(SRC)/cnst.inc \
                $(SRC)/isos.inc $(SRC)/func.inc $(SRC)/rswf.inc \
                $(SRC)/hfx.inc

hip.f:          $(SRC)/hip.F
hip.o:          hip.f $(SRC)/system.h $(SRC)/fft.inc $(SRC)/isos.inc \
                $(SRC)/cppt.inc

hipin.f:        $(SRC)/hipin.F
hipin.o:        hipin.f $(SRC)/system.h $(SRC)/isos.inc $(SRC)/cppt.inc \
                $(SRC)/fft.inc $(SRC)/cnst.inc $(SRC)/gvec.inc \
                $(SRC)/geq0.inc

hnlmat.f:       $(SRC)/hnlmat.F
hnlmat.o:       hnlmat.f $(SRC)/system.h $(SRC)/nlps.inc $(SRC)/ions.inc \
                $(SRC)/pslo.inc $(SRC)/cvan.inc $(SRC)/sfac.inc \
                $(SRC)/cppt.inc $(SRC)/spin.inc $(SRC)/sgpp.inc

hpfft.f:        $(SRC)/hpfft.F
hpfft.o:        hpfft.f $(SRC)/system.h $(SRC)/fft.inc

hpsi.f:         $(SRC)/hpsi.F
hpsi.o:         hpsi.f $(SRC)/system.h $(SRC)/pslo.inc $(SRC)/ions.inc \
                $(SRC)/cvan.inc $(SRC)/elct.inc $(SRC)/norm.inc \
                $(SRC)/geq0.inc $(SRC)/spin.inc $(SRC)/nlps.inc \
                $(SRC)/kpts.inc $(SRC)/fft.inc

htrstr.f:       $(SRC)/htrstr.F
htrstr.o:       htrstr.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/cppt.inc \
                $(SRC)/geq0.inc $(SRC)/sfac.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/strs.inc $(SRC)/str2.inc \
                $(SRC)/ragg.inc

initclust.f:    $(SRC)/initclust.F
initclust.o:    initclust.f $(SRC)/system.h $(SRC)/isos.inc \
                $(SRC)/cppt.inc $(SRC)/cnst.inc $(SRC)/geq0.inc \
                $(SRC)/ener.inc $(SRC)/func.inc $(SRC)/elct.inc \
                $(SRC)/rswf.inc $(SRC)/fft.inc $(SRC)/kpts.inc \
                $(SRC)/spin.inc $(SRC)/pslo.inc $(SRC)/hfx.inc

initrun.f:      $(SRC)/initrun.F
initrun.o:      initrun.f $(SRC)/system.h $(SRC)/tpar.inc $(SRC)/elct.inc \
                $(SRC)/pslo.inc $(SRC)/norm.inc $(SRC)/ropt.inc \
                $(SRC)/cppt.inc $(SRC)/sfac.inc $(SRC)/coor.inc \
                $(SRC)/nlcc.inc $(SRC)/ions.inc $(SRC)/isos.inc \
                $(SRC)/nlps.inc $(SRC)/fint.inc $(SRC)/poin.inc \
                $(SRC)/andr.inc $(SRC)/andp.inc $(SRC)/cnst.inc \
                $(SRC)/spin.inc $(SRC)/metr.inc $(SRC)/kpts.inc \
                $(SRC)/shop.inc $(SRC)/store.inc $(SRC)/linres.inc \
                $(SRC)/bsym.inc $(SRC)/mm_dim.inc $(SRC)/mm_input.inc

inr_dr.f:       $(SRC)/inr_dr.F
inr_dr.o:       inr_dr.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cotr.inc \
                $(SRC)/xinr.inc $(SRC)/response_p.inc $(SRC)/fft.inc \
                $(SRC)/implhv.inc $(SRC)/coor.inc $(SRC)/sfac.inc \
                $(SRC)/ropt.inc $(SRC)/norm.inc $(SRC)/soft.inc \
                $(DEST)/irat.inc $(SRC)/ener.inc $(SRC)/elct.inc \
                $(SRC)/nlps.inc $(SRC)/cppt.inc $(SRC)/cnst.inc \
                $(SRC)/rmas.inc $(SRC)/fileopen.inc

inscan.f:       $(SRC)/inscan.F
inscan.o:       inscan.f $(SRC)/store.inc

interaction_manno_p.f:$(SRC)/interaction_manno_p.F
interaction_manno_p.o:interaction_manno_p.f $(SRC)/system.h \
                $(SRC)/response_p.inc $(SRC)/prop.inc $(SRC)/cnst.inc \
                $(SRC)/cppt.inc $(SRC)/ddip.inc $(SRC)/isos.inc \
                $(SRC)/wann.inc $(SRC)/coor.inc $(SRC)/store.inc \
                $(SRC)/ropt.inc $(SRC)/sfac.inc $(SRC)/elct.inc \
                $(SRC)/ener.inc $(SRC)/fft.inc $(SRC)/atwf.inc \
                $(SRC)/nlcc.inc $(SRC)/kpnt.inc $(SRC)/tpar.inc \
                $(SRC)/fileopen.inc $(SRC)/gvec.inc $(SRC)/ions.inc \
                $(SRC)/geq0.inc $(DEST)/irat.inc

interaction_p.f:$(SRC)/interaction_p.F
interaction_p.o:interaction_p.f $(SRC)/system.h $(SRC)/response_p.inc \
                $(SRC)/prop.inc $(SRC)/cnst.inc $(SRC)/cppt.inc \
                $(SRC)/ddip.inc $(SRC)/isos.inc $(SRC)/wann.inc \
                $(SRC)/coor.inc $(SRC)/store.inc $(SRC)/ropt.inc \
                $(SRC)/sfac.inc $(SRC)/elct.inc $(SRC)/ener.inc \
                $(SRC)/fft.inc $(SRC)/atwf.inc $(SRC)/nlcc.inc \
                $(SRC)/kpnt.inc $(SRC)/tpar.inc $(SRC)/geq0.inc \
                $(DEST)/irat.inc

interp3d.f:     $(SRC)/interp3d.F
interp3d.o:     interp3d.f

interpt.f:      $(SRC)/interpt.F
interpt.o:      interpt.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/ions.inc \
                $(SRC)/pslo.inc $(SRC)/ddip.inc

jacobi_c.f:     $(SRC)/jacobi_c.F
jacobi_c.o:     jacobi_c.f

jacobi.f:       $(SRC)/jacobi.F
jacobi.o:       jacobi.f

jrotation.f:    $(SRC)/jrotation.F
jrotation.o:    jrotation.f $(SRC)/system.h $(SRC)/wann.inc \
                $(SRC)/cnst.inc $(SRC)/spin.inc $(SRC)/pslo.inc \
                $(SRC)/isos.inc

k290_2.f:       $(SRC)/k290_2.F
k290_2.o:       k290_2.f

k290.f:         $(SRC)/k290.F
k290.o:         k290.f

kddipo.f:       $(SRC)/kddipo.F
kddipo.o:       kddipo.f $(SRC)/system.h $(SRC)/kpnt.inc $(SRC)/kpts.inc \
                $(DEST)/irat.inc $(SRC)/store.inc

k_diis_rhofix.f:$(SRC)/k_diis_rhofix.F
k_diis_rhofix.o:k_diis_rhofix.f $(SRC)/system.h $(SRC)/norm.inc \
                $(SRC)/ions.inc $(SRC)/ropt.inc $(SRC)/tpar.inc \
                $(SRC)/soft.inc $(SRC)/pslo.inc $(SRC)/cppt.inc \
                $(SRC)/geq0.inc $(SRC)/ener.inc $(SRC)/kpnt.inc \
                $(SRC)/kpts.inc $(SRC)/elct.inc $(SRC)/spin.inc \
                $(SRC)/store.inc

kdp_diag.f:     $(SRC)/kdp_diag.F
kdp_diag.o:     kdp_diag.f $(SRC)/system.h $(SRC)/cnst.inc \
                $(SRC)/elct.inc $(SRC)/ropt.inc

kdpoints.f:     $(SRC)/kdpoints.F
kdpoints.o:     kdpoints.f $(SRC)/system.h $(SRC)/gvec.inc \
                $(SRC)/kdp.inc $(SRC)/kdpc.inc $(SRC)/kpnt.inc \
                $(DEST)/irat.inc

kdp_prep.f:     $(SRC)/kdp_prep.F
kdp_prep.o:     kdp_prep.f $(SRC)/system.h $(SRC)/cppt.inc \
                $(SRC)/spin.inc $(SRC)/cnst.inc

kdp_rho.f:      $(SRC)/kdp_rho.F
kdp_rho.o:      kdp_rho.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/fft.inc

kdp_stress_kin.f:$(SRC)/kdp_stress_kin.F
kdp_stress_kin.o:kdp_stress_kin.f $(SRC)/system.h $(SRC)/cnst.inc \
                $(SRC)/strs.inc

k_forces.f:     $(SRC)/k_forces.F
k_forces.o:     k_forces.f $(SRC)/system.h $(SRC)/norm.inc \
                $(SRC)/pslo.inc $(SRC)/ropt.inc $(SRC)/elct.inc \
                $(SRC)/fft.inc $(SRC)/geq0.inc $(SRC)/cppt.inc \
                $(SRC)/spin.inc $(SRC)/ions.inc $(SRC)/kpts.inc \
                $(SRC)/cvan.inc $(SRC)/nlps.inc $(SRC)/sfac.inc \
                $(SRC)/ener.inc $(SRC)/kpnt.inc $(SRC)/tpar.inc \
                $(SRC)/andp.inc $(SRC)/response_p.inc $(SRC)/cnst.inc \
                $(SRC)/broy.inc $(SRC)/time.inc $(SRC)/envj.inc \
                $(SRC)/rswf.inc $(SRC)/vdwc.inc $(DEST)/irat.inc

k_hesele.f:     $(SRC)/k_hesele.F
k_hesele.o:     k_hesele.f $(SRC)/system.h $(SRC)/cppt.inc \
                $(SRC)/nlps.inc $(SRC)/ions.inc $(SRC)/pslo.inc \
                $(SRC)/cvan.inc $(SRC)/sgpp.inc $(SRC)/simul.inc \
                $(SRC)/kpnt.inc

kin_energy.f:   $(SRC)/kin_energy.F
kin_energy.o:   kin_energy.f $(SRC)/system.h $(SRC)/ener.inc \
                $(SRC)/elct.inc $(SRC)/geq0.inc $(SRC)/cppt.inc \
                $(SRC)/prcp.inc $(SRC)/spin.inc

k_odiis.f:      $(SRC)/k_odiis.F
k_odiis.o:      k_odiis.f $(SRC)/system.h $(SRC)/ener.inc $(SRC)/elct.inc \
                $(SRC)/geq0.inc $(SRC)/kpts.inc

k_pcgrad.f:     $(SRC)/k_pcgrad.F
k_pcgrad.o:     k_pcgrad.f $(SRC)/system.h $(SRC)/ions.inc \
                $(SRC)/ener.inc $(SRC)/elct.inc $(SRC)/tpar.inc \
                $(SRC)/pslo.inc $(SRC)/nlps.inc $(SRC)/ropt.inc \
                $(SRC)/kpnt.inc $(SRC)/kpts.inc $(DEST)/irat.inc

kpclean.f:      $(SRC)/kpclean.F
kpclean.o:      kpclean.f $(SRC)/system.h $(SRC)/sphe.inc

kpert_potential_p.f:$(SRC)/kpert_potential_p.F
kpert_potential_p.o:kpert_potential_p.f $(SRC)/system.h $(SRC)/nlps.inc \
                $(SRC)/ions.inc $(SRC)/pslo.inc $(SRC)/sfac.inc \
                $(SRC)/cppt.inc $(SRC)/sgpp.inc $(SRC)/kpnt.inc \
                $(SRC)/geq0.inc $(SRC)/response_p.inc $(SRC)/kpts.inc

kpert_util_p.f: $(SRC)/kpert_util_p.F
kpert_util_p.o: kpert_util_p.f $(SRC)/system.h $(SRC)/sfac.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/response_p.inc

ksdiag.f:       $(SRC)/ksdiag.F
ksdiag.o:       ksdiag.f $(SRC)/system.h $(SRC)/cppt.inc $(SRC)/nlps.inc \
                $(SRC)/cnst.inc $(SRC)/ions.inc $(SRC)/pslo.inc \
                $(SRC)/cvan.inc $(SRC)/sgpp.inc $(SRC)/simul.inc

ks_ener_p.f:    $(SRC)/ks_ener_p.F
ks_ener_p.o:    ks_ener_p.f $(SRC)/system.h $(SRC)/ions.inc \
                $(SRC)/cnst.inc $(SRC)/coor.inc $(SRC)/sfac.inc \
                $(SRC)/elct.inc $(SRC)/kpts.inc $(SRC)/kpnt.inc \
                $(SRC)/cppt.inc $(SRC)/geq0.inc $(SRC)/response_p.inc

ksmat_dist.f:   $(SRC)/ksmat_dist.F
ksmat_dist.o:   ksmat_dist.f $(SRC)/system.h $(DEST)/irat.inc \
                $(SRC)/ions.inc $(SRC)/spin.inc $(SRC)/nlps.inc \
                $(SRC)/cnst.inc $(SRC)/cvan.inc $(SRC)/geq0.inc \
                $(SRC)/pslo.inc $(SRC)/cppt.inc $(SRC)/atwf.inc \
                $(SRC)/kpts.inc $(SRC)/ksmat.inc

ksmat.f:        $(SRC)/ksmat.F
ksmat.o:        ksmat.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/spin.inc \
                $(SRC)/nlps.inc $(SRC)/cnst.inc $(SRC)/cvan.inc \
                $(SRC)/geq0.inc $(SRC)/pslo.inc $(SRC)/cppt.inc \
                $(SRC)/atwf.inc $(SRC)/kpts.inc

k_updwf.f:      $(SRC)/k_updwf.F
k_updwf.o:      k_updwf.f $(SRC)/system.h $(SRC)/norm.inc $(SRC)/ions.inc \
                $(SRC)/ropt.inc $(SRC)/tpar.inc $(SRC)/soft.inc \
                $(SRC)/pslo.inc $(SRC)/cppt.inc $(SRC)/geq0.inc \
                $(SRC)/ener.inc $(SRC)/kpnt.inc $(SRC)/elct.inc \
                $(SRC)/spin.inc

lanc_phon_p.f:  $(SRC)/lanc_phon_p.F
lanc_phon_p.o:  lanc_phon_p.f $(SRC)/system.h $(SRC)/ions.inc \
                $(DEST)/irat.inc $(SRC)/symm.inc $(SRC)/rmas.inc \
                $(SRC)/cotr.inc $(SRC)/adat.inc $(SRC)/coor.inc \
                $(SRC)/soft.inc $(SRC)/store.inc $(SRC)/elct.inc \
                $(SRC)/spin.inc $(SRC)/sfac.inc $(SRC)/nlps.inc \
                $(SRC)/pslo.inc $(SRC)/atwf.inc $(SRC)/kpts.inc \
                $(SRC)/kpnt.inc $(SRC)/fft.inc $(SRC)/response_p.inc \
                $(SRC)/cppt.inc $(SRC)/geq0.inc $(SRC)/prop.inc \
                $(SRC)/implhv.inc $(SRC)/fileopen.inc

latgen.f:       $(SRC)/latgen.F
latgen.o:       latgen.f

ldos.f:         $(SRC)/ldos.F
ldos.o:         ldos.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/elct.inc \
                $(SRC)/cnst.inc $(SRC)/geq0.inc $(SRC)/pslo.inc \
                $(SRC)/ener.inc $(SRC)/cppt.inc $(SRC)/sfac.inc \
                $(SRC)/fft.inc $(SRC)/ions.inc $(SRC)/prcp.inc \
                $(SRC)/ropt.inc $(SRC)/ldos.inc $(SRC)/kpts.inc \
                $(SRC)/kpnt.inc $(SRC)/fileopen.inc

legendre_p.f:   $(SRC)/legendre_p.F
legendre_p.o:   legendre_p.f $(SRC)/cnst.inc

linalg.f:       $(SRC)/linalg.F
linalg.o:       linalg.f $(SRC)/system.h

loadpa.f:       $(SRC)/loadpa.F
loadpa.o:       loadpa.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/gvec.inc \
                $(DEST)/irat.inc $(SRC)/cppt.inc $(SRC)/isos.inc \
                $(SRC)/pslo.inc $(SRC)/nlps.inc $(SRC)/geq0.inc \
                $(SRC)/nlcc.inc $(SRC)/kpts.inc $(SRC)/sfac.inc \
                $(SRC)/sphe.inc $(SRC)/ions.inc $(SRC)/mm_dim.inc

loadse.f:       $(SRC)/loadse.F
loadse.o:       loadse.f $(SRC)/system.h $(SRC)/gvec.inc $(SRC)/elct.inc \
                $(DEST)/irat.inc $(SRC)/cppt.inc $(SRC)/cell.inc \
                $(SRC)/metr.inc $(SRC)/sphe.inc $(SRC)/ions.inc \
                $(SRC)/mm_dim.inc

localize.f:     $(SRC)/localize.F
localize.o:     localize.f $(SRC)/system.h $(SRC)/geq0.inc \
                $(SRC)/ions.inc $(SRC)/cnst.inc $(SRC)/ddip.inc \
                $(SRC)/gvec.inc $(DEST)/irat.inc $(SRC)/rmas.inc \
                $(SRC)/wann.inc $(SRC)/spin.inc $(SRC)/store.inc \
                $(SRC)/ropt.inc $(SRC)/linres.inc $(SRC)/response_p.inc

lodipo.f:       $(SRC)/lodipo.F
lodipo.o:       lodipo.f $(SRC)/system.h $(SRC)/lodp.inc $(SRC)/cppt.inc \
                $(SRC)/ions.inc $(SRC)/cnst.inc $(SRC)/geq0.inc

lowdin.f:       $(SRC)/lowdin.F
lowdin.o:       lowdin.f $(SRC)/system.h $(SRC)/sfac.inc $(SRC)/ions.inc \
                $(SRC)/geq0.inc $(SRC)/pslo.inc $(SRC)/spin.inc

lr_diag.f:      $(SRC)/lr_diag.F
lr_diag.o:      lr_diag.f $(SRC)/system.h $(SRC)/linres.inc \
                $(SRC)/elct.inc $(SRC)/spin.inc

lr_force.f:     $(SRC)/lr_force.F
lr_force.o:     lr_force.f $(SRC)/system.h $(SRC)/elct.inc \
                $(SRC)/spin.inc $(SRC)/poin.inc $(SRC)/rswf.inc

lr_in.f:        $(SRC)/lr_in.F
lr_in.o:        lr_in.f $(SRC)/system.h $(SRC)/spin.inc $(DEST)/irat.inc \
                $(SRC)/linres.inc $(SRC)/tpot.inc $(SRC)/mols.inc \
                $(SRC)/adat.inc $(SRC)/ions.inc $(SRC)/coor.inc

lr_ortho.f:     $(SRC)/lr_ortho.F
lr_ortho.o:     lr_ortho.f $(SRC)/system.h $(SRC)/cppt.inc \
                $(SRC)/spin.inc $(SRC)/geq0.inc $(SRC)/elct.inc \
                $(SRC)/linres.inc

lr_pcg.f:       $(SRC)/lr_pcg.F
lr_pcg.o:       lr_pcg.f $(SRC)/system.h $(SRC)/linres.inc \
                $(SRC)/elct.inc $(SRC)/spin.inc $(SRC)/poin.inc \
                $(SRC)/cnst.inc $(SRC)/cppt.inc $(SRC)/geq0.inc \
                $(SRC)/fft.inc $(SRC)/isos.inc

lr_tddft.f:     $(SRC)/lr_tddft.F
lr_tddft.o:     lr_tddft.f $(SRC)/system.h $(SRC)/elct.inc \
                $(SRC)/poin.inc $(SRC)/spin.inc $(SRC)/isos.inc \
                $(SRC)/ener.inc $(SRC)/nlcc.inc $(SRC)/tpot.inc \
                $(SRC)/tauf.inc $(SRC)/linres.inc $(SRC)/efld.inc \
                $(SRC)/mm_input.inc $(SRC)/mm_dim.inc $(SRC)/cppt.inc \
                $(SRC)/pimd.inc

lr_upd.f:       $(SRC)/lr_upd.F
lr_upd.o:       lr_upd.f $(SRC)/system.h $(SRC)/tpar.inc $(SRC)/soft.inc \
                $(SRC)/norm.inc $(SRC)/ropt.inc $(SRC)/geq0.inc \
                $(SRC)/linres.inc $(SRC)/elct.inc $(SRC)/spin.inc

lr_xcpot.f:     $(SRC)/lr_xcpot.F
lr_xcpot.o:     lr_xcpot.f $(SRC)/system.h $(SRC)/func.inc \
                $(SRC)/spin.inc $(SRC)/nlcc.inc $(SRC)/linres.inc \
                $(SRC)/tbxc.inc

lsd_elf.f:      $(SRC)/lsd_elf.F
lsd_elf.o:      lsd_elf.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/cppt.inc \
                $(SRC)/ions.inc $(SRC)/elct.inc $(SRC)/pslo.inc \
                $(SRC)/poin.inc $(SRC)/qspl.inc $(SRC)/fft.inc \
                $(SRC)/atwf.inc $(SRC)/ener.inc $(SRC)/prden.inc \
                $(SRC)/kpts.inc $(SRC)/pimd.inc $(SRC)/spin.inc \
                $(SRC)/bsym.inc

lsd_func.f:     $(SRC)/lsd_func.F
lsd_func.o:     lsd_func.f $(SRC)/func.inc

lsfbtr.f:       $(SRC)/lsfbtr.F
lsfbtr.o:       lsfbtr.f

lsforce.f:      $(SRC)/lsforce.F
lsforce.o:      lsforce.f $(SRC)/system.h $(SRC)/bsym.inc

matrix_p.f:     $(SRC)/matrix_p.F
matrix_p.o:     matrix_p.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/cnst.inc $(SRC)/pslo.inc $(SRC)/nlps.inc \
                $(SRC)/ions.inc $(SRC)/cppt.inc $(SRC)/geq0.inc \
                $(SRC)/kpts.inc $(SRC)/sfac.inc $(SRC)/sgpp.inc \
                $(SRC)/response_p.inc $(SRC)/ropt.inc

mdclas.f:       $(SRC)/mdclas.F
mdclas.o:       mdclas.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/ener.inc \
                $(SRC)/elct.inc $(SRC)/tpar.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/soft.inc $(SRC)/nose.inc \
                $(SRC)/norm.inc $(SRC)/ropt.inc $(SRC)/cppt.inc \
                $(SRC)/coor.inc $(SRC)/geq0.inc $(SRC)/spin.inc \
                $(DEST)/irat.inc $(SRC)/nlcc.inc $(SRC)/cotr.inc \
                $(SRC)/nlps.inc $(SRC)/store.inc $(SRC)/kpts.inc \
                $(SRC)/clas.inc $(SRC)/temps.inc $(SRC)/comvel.inc \
                $(SRC)/fileopen.inc $(SRC)/metr.inc $(SRC)/movi.inc

mddiag.f:       $(SRC)/mddiag.F
mddiag.o:       mddiag.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/ener.inc \
                $(SRC)/elct.inc $(SRC)/tpar.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/soft.inc $(SRC)/nose.inc \
                $(SRC)/norm.inc $(SRC)/ropt.inc $(SRC)/cppt.inc \
                $(SRC)/coor.inc $(SRC)/geq0.inc $(SRC)/spin.inc \
                $(DEST)/irat.inc $(SRC)/nlcc.inc $(SRC)/cotr.inc \
                $(SRC)/andr.inc $(SRC)/andp.inc $(SRC)/nlps.inc \
                $(SRC)/fint.inc $(SRC)/poin.inc $(SRC)/kpts.inc \
                $(SRC)/kpnt.inc $(SRC)/atwf.inc $(SRC)/store.inc \
                $(SRC)/linres.inc $(SRC)/response_p.inc $(SRC)/comvel.inc \
                $(SRC)/bsym.inc $(SRC)/cnst_dyn.inc $(SRC)/fileopen.inc \
                $(SRC)/mm_extrap.inc

mddiag-interaction_p.f:$(SRC)/mddiag-interaction_p.F
mddiag-interaction_p.o:mddiag-interaction_p.f $(SRC)/system.h \
                $(SRC)/spin.inc $(SRC)/elct.inc $(SRC)/ener.inc \
                $(SRC)/norm.inc $(SRC)/ropt.inc $(SRC)/andr.inc \
                $(SRC)/andp.inc $(SRC)/soft.inc $(SRC)/store.inc \
                $(SRC)/response_p.inc $(SRC)/wann.inc $(SRC)/prop.inc \
                $(SRC)/ddip.inc $(DEST)/irat.inc $(SRC)/cppt.inc \
                $(SRC)/cnst.inc

mdfile.f:       $(SRC)/mdfile.F
mdfile.o:       mdfile.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/ener.inc \
                $(SRC)/elct.inc $(SRC)/tpar.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/soft.inc $(SRC)/nose.inc \
                $(SRC)/norm.inc $(SRC)/ropt.inc $(SRC)/cppt.inc \
                $(SRC)/coor.inc $(SRC)/geq0.inc $(SRC)/spin.inc \
                $(DEST)/irat.inc $(SRC)/nlcc.inc $(SRC)/cotr.inc \
                $(SRC)/andr.inc $(SRC)/andp.inc $(SRC)/nlps.inc \
                $(SRC)/fint.inc $(SRC)/poin.inc $(SRC)/kpts.inc \
                $(SRC)/kpnt.inc $(SRC)/atwf.inc $(SRC)/store.inc \
                $(SRC)/linres.inc $(SRC)/response_p.inc $(SRC)/comvel.inc \
                $(SRC)/fileopen.inc

mdmain.f:       $(SRC)/mdmain.F
mdmain.o:       mdmain.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/ener.inc \
                $(SRC)/elct.inc $(SRC)/tpar.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/soft.inc $(SRC)/nose.inc \
                $(SRC)/norm.inc $(SRC)/ropt.inc $(SRC)/cppt.inc \
                $(SRC)/coor.inc $(SRC)/geq0.inc $(SRC)/spin.inc \
                $(DEST)/irat.inc $(SRC)/nlcc.inc $(SRC)/cotr.inc \
                $(SRC)/nlps.inc $(SRC)/store.inc $(SRC)/kpts.inc \
                $(SRC)/wann.inc $(SRC)/cnst_dyn.inc $(SRC)/adat.inc \
                $(SRC)/comvel.inc $(SRC)/bsym.inc $(SRC)/bsympnt.inc \
                $(SRC)/fileopen.inc

mdpt.f:         $(SRC)/mdpt.F
mdpt.o:         mdpt.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/nlps.inc $(SRC)/atwf.inc \
                $(SRC)/kpts.inc $(SRC)/str2.inc $(SRC)/clas.inc \
                $(SRC)/ddip.inc $(SRC)/linres.inc $(SRC)/bsym.inc \
                $(SRC)/shop.inc $(SRC)/mm_dim.inc

mdshop_bo.f:    $(SRC)/mdshop_bo.F
mdshop_bo.o:    mdshop_bo.f $(SRC)/system.h $(SRC)/cnst.inc \
                $(SRC)/ener.inc $(SRC)/elct.inc $(SRC)/tpar.inc \
                $(SRC)/pslo.inc $(SRC)/ions.inc $(SRC)/soft.inc \
                $(SRC)/nose.inc $(SRC)/norm.inc $(SRC)/ropt.inc \
                $(SRC)/cppt.inc $(SRC)/coor.inc $(SRC)/geq0.inc \
                $(SRC)/spin.inc $(DEST)/irat.inc $(SRC)/nlcc.inc \
                $(SRC)/cotr.inc $(SRC)/andr.inc $(SRC)/andp.inc \
                $(SRC)/nlps.inc $(SRC)/fint.inc $(SRC)/poin.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/atwf.inc \
                $(SRC)/store.inc $(SRC)/linres.inc $(SRC)/response_p.inc \
                $(SRC)/comvel.inc $(SRC)/bsym.inc $(SRC)/cnst_dyn.inc \
                $(SRC)/fileopen.inc $(SRC)/wann.inc $(SRC)/shop.inc \
                $(SRC)/mm_extrap.inc

mdshop_cp.f:    $(SRC)/mdshop_cp.F
mdshop_cp.o:    mdshop_cp.f $(SRC)/system.h $(SRC)/cnst.inc \
                $(SRC)/coor.inc $(SRC)/cotr.inc $(SRC)/cppt.inc \
                $(SRC)/elct.inc $(SRC)/ener.inc $(SRC)/fileopen.inc \
                $(SRC)/geq0.inc $(SRC)/ions.inc $(DEST)/irat.inc \
                $(SRC)/kpts.inc $(SRC)/nlcc.inc $(SRC)/nlps.inc \
                $(SRC)/norm.inc $(SRC)/nose.inc $(SRC)/pslo.inc \
                $(SRC)/ropt.inc $(SRC)/shop.inc $(SRC)/soft.inc \
                $(SRC)/spin.inc $(SRC)/store.inc $(SRC)/tpar.inc \
                $(SRC)/wann.inc $(SRC)/comvel.inc

memory.f:       $(SRC)/memory.F
memory.o:       memory.f $(SRC)/system.h $(SRC)/memc.inc $(DEST)/irat.inc

meta_cell.f:    $(SRC)/meta_cell.F
meta_cell.o:    meta_cell.f $(SRC)/system.h $(SRC)/ions.inc \
                $(SRC)/cotr.inc $(SRC)/rmas.inc $(SRC)/cnst_dyn.inc \
                $(SRC)/cnst.inc $(SRC)/metr.inc $(SRC)/strs.inc \
                $(DEST)/irat.inc $(SRC)/tpar.inc $(SRC)/ropt.inc \
                $(SRC)/soft.inc $(SRC)/store.inc $(SRC)/fileopen.inc \
                $(SRC)/ener.inc $(SRC)/prcp.inc

meta_colvar.f:  $(SRC)/meta_colvar.F
meta_colvar.o:  meta_colvar.f $(SRC)/system.h $(SRC)/ions.inc \
                $(SRC)/cotr.inc $(SRC)/cnst_dyn.inc $(DEST)/irat.inc \
                $(SRC)/tpar.inc $(SRC)/ropt.inc $(SRC)/soft.inc \
                $(SRC)/store.inc $(SRC)/adat.inc $(SRC)/cnst.inc \
                $(SRC)/strs.inc $(SRC)/fileopen.inc

meta_colvar_inp.f:$(SRC)/meta_colvar_inp.F
meta_colvar_inp.o:meta_colvar_inp.f $(SRC)/system.h $(SRC)/cotr.inc \
                $(DEST)/irat.inc $(SRC)/store.inc $(SRC)/ions.inc \
                $(SRC)/prcp.inc $(SRC)/cnst_dyn.inc $(SRC)/cnst.inc \
                $(SRC)/mm_dim.inc $(SRC)/mm_input.inc

meta_colvar_util.f:$(SRC)/meta_colvar_util.F
meta_colvar_util.o:meta_colvar_util.f $(SRC)/system.h $(SRC)/cnst_dyn.inc \
                $(SRC)/ener.inc $(SRC)/nose.inc $(SRC)/cnst.inc \
                $(SRC)/ropt.inc $(SRC)/fileopen.inc $(SRC)/cotr.inc \
                $(SRC)/tpar.inc $(SRC)/ions.inc

meta_cv.f:      $(SRC)/meta_cv.F
meta_cv.o:      meta_cv.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/isos.inc \
                $(SRC)/cotr.inc $(DEST)/irat.inc $(SRC)/adat.inc \
                $(SRC)/fileopen.inc $(SRC)/cnst_dyn.inc $(SRC)/strs.inc \
                $(SRC)/metr.inc

meta_cv_qmmm.f: $(SRC)/meta_cv_qmmm.F
meta_cv_qmmm.o: meta_cv_qmmm.f $(SRC)/system.h $(SRC)/ions.inc \
                $(SRC)/isos.inc $(SRC)/cotr.inc $(SRC)/mm_dim.inc \
                $(SRC)/mm_input.inc $(DEST)/irat.inc $(SRC)/fileopen.inc

meta_dyn_def.f: $(SRC)/meta_dyn_def.F
meta_dyn_def.o: meta_dyn_def.f $(SRC)/system.h $(SRC)/cnst_dyn.inc \
                $(SRC)/store.inc

meta_exlagr.f:  $(SRC)/meta_exlagr.F
meta_exlagr.o:  meta_exlagr.f $(SRC)/system.h $(SRC)/ions.inc \
                $(SRC)/cotr.inc $(SRC)/cnst_dyn.inc $(DEST)/irat.inc \
                $(SRC)/tpar.inc $(SRC)/ropt.inc $(SRC)/soft.inc \
                $(SRC)/store.inc $(SRC)/adat.inc $(SRC)/cnst.inc \
                $(SRC)/strs.inc $(SRC)/fileopen.inc $(SRC)/mm_dim.inc

meta_exlagr_util.f:$(SRC)/meta_exlagr_util.F
meta_exlagr_util.o:meta_exlagr_util.f $(SRC)/system.h $(SRC)/cnst_dyn.inc \
                $(SRC)/cnst.inc $(SRC)/ener.inc $(SRC)/nose.inc \
                $(SRC)/ropt.inc $(SRC)/fileopen.inc $(DEST)/irat.inc \
                $(SRC)/ions.inc $(SRC)/strs.inc $(SRC)/metr.inc

meta_exl_mult.f:$(SRC)/meta_exl_mult.F
meta_exl_mult.o:meta_exl_mult.f $(SRC)/system.h $(SRC)/ions.inc \
                $(SRC)/cotr.inc $(SRC)/cnst_dyn.inc $(DEST)/irat.inc \
                $(SRC)/tpar.inc $(SRC)/ropt.inc $(SRC)/soft.inc \
                $(SRC)/store.inc $(SRC)/adat.inc $(SRC)/cnst.inc \
                $(SRC)/fileopen.inc

meta_ex_mul_util.f:$(SRC)/meta_ex_mul_util.F
meta_ex_mul_util.o:meta_ex_mul_util.f $(SRC)/system.h $(SRC)/cnst_dyn.inc \
                $(SRC)/cnst.inc $(SRC)/ener.inc $(SRC)/nose.inc \
                $(SRC)/ropt.inc $(SRC)/fileopen.inc

metafun.f:      $(SRC)/metafun.F
metafun.o:      metafun.f $(SRC)/func.inc

meta_hpot.f:    $(SRC)/meta_hpot.F
meta_hpot.o:    meta_hpot.f $(SRC)/system.h $(SRC)/cnst_dyn.inc \
                $(SRC)/cnst.inc

meta_localizespin.f:$(SRC)/meta_localizespin.F
meta_localizespin.o:meta_localizespin.f $(SRC)/system.h $(SRC)/gvec.inc \
                $(SRC)/cell.inc $(DEST)/irat.inc $(SRC)/prcp.inc \
                $(SRC)/spin.inc $(SRC)/fft.inc $(SRC)/cnst_dyn.inc \
                $(SRC)/coor.inc $(SRC)/ions.inc

mixing_g.f:     $(SRC)/mixing_g.F
mixing_g.o:     mixing_g.f $(SRC)/system.h $(SRC)/andr.inc \
                $(SRC)/broy.inc $(SRC)/spin.inc $(SRC)/geq0.inc \
                $(SRC)/cppt.inc

mixing_r.f:     $(SRC)/mixing_r.F
mixing_r.o:     mixing_r.f $(SRC)/system.h $(SRC)/andr.inc \
                $(SRC)/spin.inc

mltfft.f:       $(SRC)/mltfft.F
mltfft.o:       mltfft.f $(SRC)/system.h

mm_cpmd_add_MM_forces_f77.f:$(SRC)/mm_cpmd_add_MM_forces_f77.F
mm_cpmd_add_MM_forces_f77.o:mm_cpmd_add_MM_forces_f77.f $(SRC)/system.h \
                $(SRC)/ions.inc $(SRC)/adat.inc

mm_cpmd_esp_charges_f77.f:$(SRC)/mm_cpmd_esp_charges_f77.F
mm_cpmd_esp_charges_f77.o:mm_cpmd_esp_charges_f77.f $(SRC)/system.h \
                $(SRC)/elct.inc $(SRC)/epot.inc $(SRC)/efld.inc \
                $(SRC)/ions.inc $(SRC)/ener.inc $(SRC)/prop.inc \
                $(SRC)/dipo.inc $(SRC)/lodp.inc $(SRC)/atwf.inc \
                $(SRC)/geq0.inc $(SRC)/isos.inc $(SRC)/cppt.inc \
                $(DEST)/irat.inc $(SRC)/pslo.inc $(SRC)/fft.inc

mm_cpmd_ext_pot_f77.f:$(SRC)/mm_cpmd_ext_pot_f77.F
mm_cpmd_ext_pot_f77.o:mm_cpmd_ext_pot_f77.f $(SRC)/system.h \
                $(SRC)/epot.inc $(SRC)/efld.inc $(SRC)/cell.inc

mm_dim.f:       $(SRC)/mm_dim.F
mm_dim.o:       mm_dim.f $(SRC)/system.h $(SRC)/tpar.inc $(SRC)/ions.inc \
                $(SRC)/mm_dim.inc $(SRC)/mm_input.inc

mm_forces_diag.f:$(SRC)/mm_forces_diag.F
mm_forces_diag.o:mm_forces_diag.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/elct.inc $(SRC)/ener.inc $(SRC)/norm.inc \
                $(SRC)/ropt.inc $(SRC)/andr.inc $(SRC)/andp.inc \
                $(SRC)/soft.inc $(SRC)/store.inc $(SRC)/linres.inc \
                $(SRC)/mm_input.inc $(DEST)/irat.inc $(SRC)/mm_extrap.inc

mm_init.f:      $(SRC)/mm_init.F
mm_init.o:      mm_init.f $(SRC)/system.h $(DEST)/irat.inc \
                $(SRC)/coor.inc $(SRC)/rmas.inc $(SRC)/ions.inc \
                $(SRC)/store.inc $(SRC)/isos.inc $(SRC)/cotr.inc \
                $(SRC)/cell.inc $(SRC)/mm_dim.inc $(SRC)/mm_input.inc \
                $(SRC)/mm_ion_dens.inc

mm_mddiag.f:    $(SRC)/mm_mddiag.F
mm_mddiag.o:    mm_mddiag.f $(SRC)/system.h $(SRC)/cnst.inc \
                $(SRC)/ener.inc $(SRC)/elct.inc $(SRC)/tpar.inc \
                $(SRC)/pslo.inc $(SRC)/ions.inc $(SRC)/soft.inc \
                $(SRC)/nose.inc $(SRC)/norm.inc $(SRC)/ropt.inc \
                $(SRC)/cppt.inc $(SRC)/coor.inc $(SRC)/geq0.inc \
                $(SRC)/spin.inc $(DEST)/irat.inc $(SRC)/nlcc.inc \
                $(SRC)/cotr.inc $(SRC)/andr.inc $(SRC)/andp.inc \
                $(SRC)/nlps.inc $(SRC)/fint.inc $(SRC)/poin.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/atwf.inc \
                $(SRC)/store.inc $(SRC)/linres.inc $(SRC)/response_p.inc \
                $(SRC)/rmas.inc $(SRC)/isos.inc $(SRC)/cnst_dyn.inc \
                $(SRC)/comvel.inc $(SRC)/fileopen.inc $(SRC)/efld.inc \
                $(SRC)/mm_dim.inc $(SRC)/mm_input.inc $(SRC)/mm_extrap.inc

mm_mdmain.f:    $(SRC)/mm_mdmain.F
mm_mdmain.o:    mm_mdmain.f $(SRC)/system.h $(SRC)/cnst.inc \
                $(SRC)/ener.inc $(SRC)/elct.inc $(SRC)/tpar.inc \
                $(SRC)/pslo.inc $(SRC)/ions.inc $(SRC)/soft.inc \
                $(SRC)/nose.inc $(SRC)/norm.inc $(SRC)/ropt.inc \
                $(SRC)/cppt.inc $(SRC)/coor.inc $(SRC)/geq0.inc \
                $(SRC)/spin.inc $(DEST)/irat.inc $(SRC)/nlcc.inc \
                $(SRC)/cotr.inc $(SRC)/nlps.inc $(SRC)/store.inc \
                $(SRC)/kpts.inc $(SRC)/wann.inc $(SRC)/rmas.inc \
                $(SRC)/cnst_dyn.inc $(SRC)/adat.inc $(SRC)/comvel.inc \
                $(SRC)/fileopen.inc $(SRC)/bsym.inc $(SRC)/efld.inc \
                $(SRC)/mm_dim.inc $(SRC)/mm_input.inc

mm_mdshop_bo.f: $(SRC)/mm_mdshop_bo.F
mm_mdshop_bo.o: mm_mdshop_bo.f $(SRC)/system.h $(SRC)/cnst.inc \
                $(SRC)/ener.inc $(SRC)/elct.inc $(SRC)/tpar.inc \
                $(SRC)/pslo.inc $(SRC)/ions.inc $(SRC)/soft.inc \
                $(SRC)/nose.inc $(SRC)/norm.inc $(SRC)/ropt.inc \
                $(SRC)/cppt.inc $(SRC)/coor.inc $(SRC)/geq0.inc \
                $(SRC)/spin.inc $(DEST)/irat.inc $(SRC)/nlcc.inc \
                $(SRC)/cotr.inc $(SRC)/andr.inc $(SRC)/andp.inc \
                $(SRC)/nlps.inc $(SRC)/fint.inc $(SRC)/poin.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/atwf.inc \
                $(SRC)/store.inc $(SRC)/linres.inc $(SRC)/response_p.inc \
                $(SRC)/rmas.inc $(SRC)/isos.inc $(SRC)/cnst_dyn.inc \
                $(SRC)/comvel.inc $(SRC)/fileopen.inc $(SRC)/shop.inc \
                $(SRC)/wann.inc $(SRC)/efld.inc $(SRC)/mm_dim.inc \
                $(SRC)/mm_input.inc $(SRC)/mm_extrap.inc

mm_mdshop_cp.f: $(SRC)/mm_mdshop_cp.F
mm_mdshop_cp.o: mm_mdshop_cp.f $(SRC)/system.h $(SRC)/cnst.inc \
                $(SRC)/ener.inc $(SRC)/elct.inc $(SRC)/tpar.inc \
                $(SRC)/pslo.inc $(SRC)/ions.inc $(SRC)/soft.inc \
                $(SRC)/nose.inc $(SRC)/norm.inc $(SRC)/ropt.inc \
                $(SRC)/cppt.inc $(SRC)/coor.inc $(SRC)/geq0.inc \
                $(SRC)/spin.inc $(DEST)/irat.inc $(SRC)/nlcc.inc \
                $(SRC)/cotr.inc $(SRC)/nlps.inc $(SRC)/store.inc \
                $(SRC)/kpts.inc $(SRC)/wann.inc $(SRC)/rmas.inc \
                $(SRC)/cnst_dyn.inc $(SRC)/adat.inc $(SRC)/comvel.inc \
                $(SRC)/fileopen.inc $(SRC)/shop.inc $(SRC)/efld.inc \
                $(SRC)/mm_dim.inc $(SRC)/mm_input.inc

mm_qmmm_forcedr_bs.f:$(SRC)/mm_qmmm_forcedr_bs.F
mm_qmmm_forcedr_bs.o:mm_qmmm_forcedr_bs.f $(SRC)/system.h $(SRC)/ener.inc \
                $(SRC)/elct.inc $(DEST)/irat.inc $(SRC)/ropt.inc \
                $(SRC)/bsym.inc $(SRC)/mm_input.inc $(SRC)/mm_dim.inc

mm_qmmm_forcedr.f:$(SRC)/mm_qmmm_forcedr.F
mm_qmmm_forcedr.o:mm_qmmm_forcedr.f $(SRC)/system.h $(SRC)/ener.inc \
                $(DEST)/irat.inc $(SRC)/ropt.inc $(SRC)/bsym.inc \
                $(SRC)/mm_input.inc $(SRC)/mm_dim.inc

mm_rho_forcedr.f:$(SRC)/mm_rho_forcedr.F
mm_rho_forcedr.o:mm_rho_forcedr.f $(SRC)/system.h $(SRC)/ener.inc \
                $(DEST)/irat.inc $(SRC)/ropt.inc $(SRC)/mm_input.inc \
                $(SRC)/mm_dim.inc

molorb.f:       $(SRC)/molorb.F
molorb.o:       molorb.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/spin.inc \
                $(SRC)/empf.inc $(DEST)/irat.inc $(SRC)/cnst.inc \
                $(SRC)/adat.inc $(SRC)/wann.inc

molstates.f:    $(SRC)/molstates.F
molstates.o:    molstates.f $(SRC)/system.h $(SRC)/ddip.inc \
                $(SRC)/wann.inc $(SRC)/spin.inc $(SRC)/ions.inc \
                $(SRC)/mols.inc $(DEST)/irat.inc $(SRC)/poin.inc \
                $(SRC)/cnst.inc $(SRC)/linres.inc $(SRC)/mm_input.inc

molsym.f:       $(SRC)/molsym.F
molsym.o:       molsym.f

moverho.f:      $(SRC)/moverho.F
moverho.o:      moverho.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/gvec.inc \
                $(SRC)/coor.inc $(SRC)/ions.inc $(SRC)/atwf.inc \
                $(SRC)/cppt.inc $(SRC)/geq0.inc $(SRC)/qspl.inc \
                $(SRC)/sfac.inc $(SRC)/fft.inc $(SRC)/ropt.inc

mtin.f:         $(SRC)/mtin.F
mtin.o:         mtin.f $(SRC)/system.h $(SRC)/isos.inc $(SRC)/cppt.inc \
                $(SRC)/fft.inc $(SRC)/geq0.inc $(SRC)/cnst.inc

mulliken.f:     $(SRC)/mulliken.F
mulliken.o:     mulliken.f $(SRC)/system.h $(SRC)/atom.inc \
                $(SRC)/elct.inc $(SRC)/spin.inc $(SRC)/adat.inc \
                $(SRC)/ions.inc $(SRC)/pslo.inc $(SRC)/atwf.inc \
                $(SRC)/sfac.inc $(DEST)/irat.inc $(SRC)/prop.inc

multtb.f:       $(SRC)/multtb.F
multtb.o:       multtb.f

my_para.f:      $(SRC)/my_para.F
my_para.o:      my_para.f $(SRC)/pstat.inc $(SRC)/system.h \
                $(DEST)/irat.inc $(SRC)/benc.inc

newcell.f:      $(SRC)/newcell.F
newcell.o:      newcell.f $(SRC)/system.h $(SRC)/kpts.inc

newd.f:         $(SRC)/newd.F
newd.o:         newd.f $(SRC)/system.h $(SRC)/sfac.inc $(SRC)/ions.inc \
                $(SRC)/pslo.inc $(SRC)/nlps.inc $(SRC)/cppt.inc \
                $(SRC)/cnst.inc $(SRC)/geq0.inc

nfunc.f:        $(SRC)/nfunc.F
nfunc.o:        nfunc.f

nlccset.f:      $(SRC)/nlccset.F
nlccset.o:      nlccset.f $(SRC)/system.h $(SRC)/atom.inc $(SRC)/cnst.inc \
                $(SRC)/ions.inc $(SRC)/dpot.inc $(SRC)/nlcc.inc \
                $(SRC)/cppt.inc $(SRC)/gvec.inc $(SRC)/qspl.inc \
                $(SRC)/pslo.inc $(SRC)/vdbp.inc

nlccstr.f:      $(SRC)/nlccstr.F
nlccstr.o:      nlccstr.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/cppt.inc \
                $(SRC)/strs.inc $(SRC)/sfac.inc $(SRC)/nlcc.inc \
                $(SRC)/spin.inc

nlforce.f:      $(SRC)/nlforce.F
nlforce.o:      nlforce.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/nlps.inc \
                $(SRC)/ions.inc $(SRC)/pslo.inc $(SRC)/cvan.inc \
                $(SRC)/sfac.inc $(SRC)/cppt.inc $(SRC)/sgpp.inc \
                $(SRC)/tbxc.inc

nl_res.f:       $(SRC)/nl_res.F
nl_res.o:       nl_res.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/spin.inc \
                $(SRC)/nlps.inc $(SRC)/ions.inc $(SRC)/pslo.inc \
                $(SRC)/cvan.inc $(SRC)/sfac.inc $(SRC)/cppt.inc \
                $(SRC)/sgpp.inc $(SRC)/cnst.inc $(SRC)/geq0.inc

nlsl.f:         $(SRC)/nlsl.F
nlsl.o:         nlsl.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cvan.inc \
                $(SRC)/nlps.inc $(SRC)/pslo.inc $(SRC)/sfac.inc \
                $(SRC)/strs.inc $(SRC)/str2.inc

nlsm1_s.f:      $(SRC)/nlsm1_s.F
nlsm1_s.o:      nlsm1_s.f $(SRC)/system.h $(SRC)/nlps.inc $(SRC)/ions.inc \
                $(SRC)/cppt.inc $(SRC)/sfac.inc $(SRC)/strs.inc \
                $(SRC)/str2.inc $(SRC)/geq0.inc $(SRC)/kpts.inc \
                $(SRC)/kpnt.inc

nmr_chi_p.f:    $(SRC)/nmr_chi_p.F
nmr_chi_p.o:    nmr_chi_p.f $(SRC)/system.h $(SRC)/cppt.inc \
                $(SRC)/fft.inc $(SRC)/response_p.inc

nmr_current_p.f:$(SRC)/nmr_current_p.F
nmr_current_p.o:nmr_current_p.f $(SRC)/system.h $(SRC)/cppt.inc \
                $(SRC)/coor.inc $(SRC)/cnst.inc $(SRC)/fft.inc \
                $(SRC)/ions.inc $(SRC)/geq0.inc $(SRC)/response_p.inc \
                $(SRC)/gvec.inc $(SRC)/prop.inc $(SRC)/elct.inc \
                $(SRC)/wann.inc

nmr_full_p.f:   $(SRC)/nmr_full_p.F
nmr_full_p.o:   nmr_full_p.f $(SRC)/system.h $(SRC)/response_p.inc \
                $(SRC)/soft.inc

nmr_para_p.f:   $(SRC)/nmr_para_p.F
nmr_para_p.o:   nmr_para_p.f $(SRC)/system.h $(DEST)/irat.inc \
                $(SRC)/filn.inc $(SRC)/response_p.inc

nmr_p.f:        $(SRC)/nmr_p.F
nmr_p.o:        nmr_p.f $(SRC)/system.h $(SRC)/response_p.inc \
                $(SRC)/prop.inc $(SRC)/cnst.inc $(SRC)/cppt.inc \
                $(SRC)/gvec.inc $(SRC)/ddip.inc $(SRC)/isos.inc \
                $(SRC)/wann.inc $(SRC)/coor.inc $(SRC)/store.inc \
                $(SRC)/soft.inc $(SRC)/ropt.inc $(SRC)/sfac.inc \
                $(SRC)/fft.inc $(SRC)/elct.inc

nmr_position_p.f:$(SRC)/nmr_position_p.F
nmr_position_p.o:nmr_position_p.f $(SRC)/system.h $(SRC)/gvec.inc \
                $(SRC)/response_p.inc $(SRC)/cppt.inc $(SRC)/cnst.inc \
                $(SRC)/fft.inc $(DEST)/irat.inc $(SRC)/geq0.inc \
                $(SRC)/coor.inc $(SRC)/ions.inc

nmr_shift_p.f:  $(SRC)/nmr_shift_p.F
nmr_shift_p.o:  nmr_shift_p.f $(SRC)/system.h $(SRC)/fft.inc \
                $(SRC)/response_p.inc $(SRC)/geq0.inc $(SRC)/cppt.inc \
                $(SRC)/ions.inc $(SRC)/coor.inc $(SRC)/cnst.inc \
                $(SRC)/adat.inc $(SRC)/prop.inc $(SRC)/gvec.inc

nmr_util_p.f:   $(SRC)/nmr_util_p.F
nmr_util_p.o:   nmr_util_p.f $(SRC)/system.h $(SRC)/coor.inc \
                $(SRC)/cppt.inc $(SRC)/gvec.inc $(SRC)/fft.inc \
                $(SRC)/cnst.inc $(SRC)/response_p.inc $(SRC)/ions.inc

noforce.f:      $(SRC)/noforce.F
noforce.o:      noforce.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/norm.inc \
                $(SRC)/pslo.inc $(SRC)/ropt.inc $(SRC)/cppt.inc \
                $(SRC)/nlps.inc $(SRC)/sfac.inc $(SRC)/ions.inc \
                $(SRC)/nort.inc $(SRC)/cvan.inc $(SRC)/spin.inc \
                $(SRC)/geq0.inc

norhoe.f:       $(SRC)/norhoe.F
norhoe.o:       norhoe.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/pslo.inc \
                $(SRC)/nlps.inc $(SRC)/sfac.inc $(SRC)/ions.inc \
                $(SRC)/nort.inc $(SRC)/spin.inc $(SRC)/geq0.inc

nosalloc.f:     $(SRC)/nosalloc.F
nosalloc.o:     nosalloc.f $(SRC)/system.h $(SRC)/ions.inc \
                $(SRC)/nose.inc $(SRC)/pimd.inc $(DEST)/irat.inc \
                $(SRC)/rmas.inc $(SRC)/mm_input.inc $(SRC)/mm_dim.inc \
                $(SRC)/fileopen.inc $(SRC)/bsym.inc

noscinit.f:     $(SRC)/noscinit.F
noscinit.o:     noscinit.f $(SRC)/system.h $(SRC)/nose.inc \
                $(SRC)/cnst.inc

noseinit.f:     $(SRC)/noseinit.F
noseinit.o:     noseinit.f $(SRC)/system.h $(SRC)/nose.inc

noseng.f:       $(SRC)/noseng.F
noseng.o:       noseng.f $(SRC)/system.h $(SRC)/nose.inc $(SRC)/ions.inc \
                $(SRC)/cnst.inc $(SRC)/rmas.inc $(SRC)/bsym.inc

nosepa.f:       $(SRC)/nosepa.F
nosepa.o:       nosepa.f $(SRC)/system.h $(SRC)/nose.inc $(SRC)/cnst.inc \
                $(SRC)/ions.inc $(SRC)/elct.inc $(SRC)/cotr.inc \
                $(SRC)/prcp.inc $(SRC)/isos.inc $(SRC)/pimd.inc \
                $(SRC)/mm_input.inc $(SRC)/mm_dim.inc $(DEST)/irat.inc

noseup.f:       $(SRC)/noseup.F
noseup.o:       noseup.f $(SRC)/system.h $(SRC)/nose.inc $(SRC)/metr.inc \
                $(SRC)/prcp.inc $(SRC)/rmas.inc $(SRC)/pimd.inc \
                $(SRC)/bsym.inc

nospinit.f:     $(SRC)/nospinit.F
nospinit.o:     nospinit.f $(SRC)/system.h $(SRC)/nose.inc \
                $(SRC)/ions.inc $(SRC)/cnst.inc $(SRC)/pimd.inc

npt_md.f:       $(SRC)/npt_md.F
npt_md.o:       npt_md.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/ener.inc \
                $(SRC)/elct.inc $(SRC)/tpar.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/soft.inc $(SRC)/nose.inc \
                $(SRC)/norm.inc $(SRC)/ropt.inc $(SRC)/cppt.inc \
                $(SRC)/coor.inc $(SRC)/geq0.inc $(SRC)/spin.inc \
                $(DEST)/irat.inc $(SRC)/nlcc.inc $(SRC)/strs.inc \
                $(SRC)/str2.inc $(SRC)/metr.inc $(SRC)/cotr.inc \
                $(SRC)/prcp.inc $(SRC)/store.inc $(SRC)/kpts.inc \
                $(SRC)/shock.inc $(SRC)/fileopen.inc $(SRC)/clas.inc \
                $(SRC)/comvel.inc $(SRC)/andr.inc $(SRC)/andp.inc \
                $(SRC)/poin.inc $(SRC)/mm_extrap.inc

nuclear_p.f:    $(SRC)/nuclear_p.F
nuclear_p.o:    nuclear_p.f $(SRC)/system.h $(SRC)/cell.inc \
                $(SRC)/elct.inc $(SRC)/epot.inc $(SRC)/soft.inc \
                $(SRC)/ions.inc $(SRC)/ener.inc $(SRC)/prop.inc \
                $(SRC)/dipo.inc $(SRC)/lodp.inc $(SRC)/atwf.inc \
                $(SRC)/geq0.inc $(SRC)/isos.inc $(SRC)/cppt.inc \
                $(DEST)/irat.inc $(SRC)/pslo.inc $(SRC)/fft.inc \
                $(SRC)/spin.inc $(SRC)/cnst.inc $(SRC)/rswf.inc \
                $(SRC)/prcp.inc $(SRC)/ropt.inc $(SRC)/symm.inc \
                $(SRC)/response_p.inc $(SRC)/rmas.inc $(SRC)/gvec.inc \
                $(SRC)/metr.inc $(SRC)/store.inc $(SRC)/ddip.inc \
                $(SRC)/sgpp.inc $(SRC)/nlps.inc $(SRC)/coor.inc \
                $(SRC)/nlcc.inc $(SRC)/atom.inc $(SRC)/mm_input.inc

numpw.f:        $(SRC)/numpw.F
numpw.o:        numpw.f $(SRC)/system.h $(SRC)/gvec.inc $(SRC)/kpts.inc \
                $(SRC)/sphe.inc $(SRC)/cell.inc $(SRC)/cnst.inc \
                $(SRC)/nlps.inc $(SRC)/fint.inc

odiis.f:        $(SRC)/odiis.F
odiis.o:        odiis.f $(SRC)/system.h $(SRC)/ener.inc $(SRC)/elct.inc \
                $(SRC)/geq0.inc

odiis_p.f:      $(SRC)/odiis_p.F
odiis_p.o:      odiis_p.f $(SRC)/system.h $(SRC)/ener.inc $(SRC)/elct.inc \
                $(SRC)/geq0.inc $(SRC)/response_p.inc

ohfd.f:         $(SRC)/ohfd.F
ohfd.o:         ohfd.f $(SRC)/system.h $(SRC)/soft.inc $(SRC)/pslo.inc \
                $(SRC)/nlcc.inc $(SRC)/coor.inc $(SRC)/store.inc \
                $(SRC)/ropt.inc $(SRC)/andp.inc $(SRC)/elct.inc \
                $(SRC)/spin.inc $(SRC)/poin.inc $(DEST)/irat.inc \
                $(SRC)/fileopen.inc

ohlr.f:         $(SRC)/ohlr.F
ohlr.o:         ohlr.f $(SRC)/system.h $(SRC)/soft.inc $(SRC)/pslo.inc \
                $(SRC)/nlcc.inc $(SRC)/coor.inc $(SRC)/store.inc \
                $(SRC)/ropt.inc $(SRC)/elct.inc $(SRC)/spin.inc \
                $(SRC)/poin.inc $(DEST)/irat.inc $(SRC)/ener.inc \
                $(SRC)/norm.inc $(SRC)/cppt.inc $(SRC)/geq0.inc \
                $(SRC)/cnst.inc $(SRC)/isos.inc $(SRC)/tpar.inc \
                $(SRC)/linres.inc $(SRC)/fileopen.inc $(SRC)/atom.inc \
                $(SRC)/adat.inc $(SRC)/ions.inc $(SRC)/atwf.inc \
                $(SRC)/sfac.inc $(SRC)/fft.inc

opeigr_c.f:     $(SRC)/opeigr_c.F
opeigr_c.o:     opeigr_c.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/ddip.inc

opeigr.f:       $(SRC)/opeigr.F
opeigr.o:       opeigr.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/ddip.inc \
                $(SRC)/gvec.inc $(DEST)/irat.inc $(SRC)/kpts.inc \
                $(SRC)/sphe.inc

opeigr_p.f:     $(SRC)/opeigr_p.F
opeigr_p.o:     opeigr_p.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/geq0.inc $(SRC)/ddip.inc

opt_lr.f:       $(SRC)/opt_lr.F
opt_lr.o:       opt_lr.f $(SRC)/system.h $(SRC)/tpar.inc $(SRC)/spin.inc \
                $(SRC)/norm.inc $(SRC)/ropt.inc $(SRC)/cppt.inc \
                $(SRC)/elct.inc $(SRC)/geq0.inc $(SRC)/fft.inc \
                $(SRC)/linres.inc

orbhard.f:      $(SRC)/orbhard.F
orbhard.o:      orbhard.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/elct2.inc \
                $(SRC)/pslo.inc $(SRC)/ions.inc $(SRC)/kpts.inc \
                $(SRC)/nlps.inc $(SRC)/fint.inc $(SRC)/atwf.inc \
                $(SRC)/ddip.inc $(SRC)/wann.inc $(SRC)/linres.inc \
                $(DEST)/irat.inc

orbrot.f:       $(SRC)/orbrot.F
orbrot.o:       orbrot.f $(SRC)/system.h

ortho.f:        $(SRC)/ortho.F
ortho.o:        ortho.f $(SRC)/system.h $(SRC)/pslo.inc $(SRC)/spin.inc \
                $(SRC)/nlps.inc $(SRC)/sfac.inc $(SRC)/ions.inc \
                $(SRC)/kpts.inc $(SRC)/geq0.inc $(SRC)/elct.inc

ovlap.f:        $(SRC)/ovlap.F
ovlap.o:        ovlap.f $(SRC)/system.h $(SRC)/geq0.inc $(SRC)/spin.inc

pbc.f:          $(SRC)/pbc.F
pbc.o:          pbc.f $(SRC)/system.h $(SRC)/isos.inc $(SRC)/mm_dim.inc \
                $(SRC)/bc.inc $(SRC)/metr.inc $(SRC)/clas.inc

pcgrad.f:       $(SRC)/pcgrad.F
pcgrad.o:       pcgrad.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/ener.inc \
                $(SRC)/elct.inc $(SRC)/tpar.inc $(SRC)/pslo.inc \
                $(SRC)/nlps.inc $(SRC)/ropt.inc $(SRC)/norm.inc \
                $(SRC)/mm_input.inc $(SRC)/mm_dim.inc $(SRC)/spin.inc

pcgrad_p.f:     $(SRC)/pcgrad_p.F
pcgrad_p.o:     pcgrad_p.f $(SRC)/system.h $(SRC)/response_p.inc \
                $(SRC)/norm.inc $(SRC)/geq0.inc $(SRC)/ions.inc \
                $(SRC)/nlps.inc $(SRC)/elct.inc

pert_kpoint_p.f:$(SRC)/pert_kpoint_p.F
pert_kpoint_p.o:pert_kpoint_p.f $(SRC)/system.h $(SRC)/ions.inc \
                $(SRC)/symm.inc $(SRC)/cnst.inc $(SRC)/coor.inc \
                $(SRC)/store.inc $(SRC)/elct.inc $(SRC)/ener.inc \
                $(SRC)/spin.inc $(SRC)/sfac.inc $(SRC)/nlps.inc \
                $(SRC)/pslo.inc $(SRC)/kpts.inc $(SRC)/kpnt.inc \
                $(SRC)/cppt.inc $(SRC)/gvec.inc $(SRC)/geq0.inc \
                $(SRC)/response_p.inc $(SRC)/ropt.inc

perturbation_p.f:$(SRC)/perturbation_p.F
perturbation_p.o:perturbation_p.f $(SRC)/system.h $(SRC)/elct.inc \
                $(SRC)/cppt.inc $(SRC)/response_p.inc $(SRC)/ions.inc \
                $(SRC)/coor.inc $(SRC)/spin.inc $(SRC)/pslo.inc \
                $(SRC)/geq0.inc

phfac.f:        $(SRC)/phfac.F
phfac.o:        phfac.f $(SRC)/system.h $(SRC)/gvec.inc $(SRC)/ions.inc \
                $(SRC)/cppt.inc $(SRC)/sfac.inc $(SRC)/kpts.inc \
                $(SRC)/kpnt.inc

phonons_p.f:    $(SRC)/phonons_p.F
phonons_p.o:    phonons_p.f $(SRC)/system.h $(SRC)/ions.inc \
                $(DEST)/irat.inc $(SRC)/symm.inc $(SRC)/rmas.inc \
                $(SRC)/cotr.inc $(SRC)/adat.inc $(SRC)/coor.inc \
                $(SRC)/soft.inc $(SRC)/store.inc $(SRC)/elct.inc \
                $(SRC)/spin.inc $(SRC)/sfac.inc $(SRC)/nlps.inc \
                $(SRC)/pslo.inc $(SRC)/atwf.inc $(SRC)/kpts.inc \
                $(SRC)/kpnt.inc $(SRC)/cppt.inc $(SRC)/fft.inc \
                $(SRC)/response_p.inc $(SRC)/implhv.inc $(SRC)/prop.inc \
                $(SRC)/ropt.inc

pi_cntl.f:      $(SRC)/pi_cntl.F
pi_cntl.o:      pi_cntl.f $(SRC)/system.h $(SRC)/pimd.inc $(SRC)/cotr.inc \
                $(SRC)/ions.inc $(DEST)/irat.inc $(SRC)/ropt.inc \
                $(SRC)/store.inc

pi_diag.f:      $(SRC)/pi_diag.F
pi_diag.o:      pi_diag.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/ener.inc \
                $(SRC)/elct.inc $(SRC)/tpar.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/soft.inc $(SRC)/nose.inc \
                $(SRC)/norm.inc $(SRC)/ropt.inc $(SRC)/cppt.inc \
                $(SRC)/coor.inc $(SRC)/geq0.inc $(SRC)/spin.inc \
                $(DEST)/irat.inc $(SRC)/nlcc.inc $(SRC)/cotr.inc \
                $(SRC)/pimd.inc $(SRC)/filn.inc $(SRC)/isos.inc \
                $(SRC)/andr.inc $(SRC)/andp.inc $(SRC)/nlps.inc \
                $(SRC)/fint.inc $(SRC)/poin.inc $(SRC)/kpts.inc \
                $(SRC)/kpnt.inc $(SRC)/atwf.inc $(SRC)/store.inc \
                $(SRC)/fileopen.inc

pi_init.f:      $(SRC)/pi_init.F
pi_init.o:      pi_init.f $(SRC)/system.h $(SRC)/pimd.inc $(SRC)/ions.inc \
                $(SRC)/rmas.inc $(SRC)/cnst.inc $(DEST)/irat.inc \
                $(SRC)/adat.inc $(SRC)/fileopen.inc

pi_md.f:        $(SRC)/pi_md.F
pi_md.o:        pi_md.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/ener.inc \
                $(SRC)/elct.inc $(SRC)/tpar.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/soft.inc $(SRC)/nose.inc \
                $(SRC)/norm.inc $(SRC)/ropt.inc $(SRC)/cppt.inc \
                $(SRC)/coor.inc $(SRC)/geq0.inc $(SRC)/spin.inc \
                $(DEST)/irat.inc $(SRC)/nlcc.inc $(SRC)/cotr.inc \
                $(SRC)/pimd.inc $(SRC)/filn.inc $(SRC)/isos.inc \
                $(SRC)/store.inc $(SRC)/fileopen.inc

pi_mdpt.f:      $(SRC)/pi_mdpt.F
pi_mdpt.o:      pi_mdpt.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/sfac.inc $(SRC)/pimd.inc \
                $(SRC)/atwf.inc $(SRC)/kpts.inc $(SRC)/ddip.inc

pinmtrans.f:    $(SRC)/pinmtrans.F
pinmtrans.o:    pinmtrans.f $(SRC)/system.h $(SRC)/ions.inc \
                $(SRC)/pimd.inc

pi_wf.f:        $(SRC)/pi_wf.F
pi_wf.o:        pi_wf.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/ions.inc \
                $(SRC)/coor.inc $(SRC)/pimd.inc $(SRC)/filn.inc \
                $(SRC)/store.inc

plotband.f:     $(SRC)/plotband.F
plotband.o:     plotband.f

pm_cntl.f:      $(SRC)/pm_cntl.F
pm_cntl.o:      pm_cntl.f $(SRC)/system.h $(SRC)/pimd.inc $(SRC)/cotr.inc \
                $(SRC)/ions.inc $(DEST)/irat.inc $(SRC)/ropt.inc \
                $(SRC)/store.inc $(SRC)/mfep.inc

pm_gmopts.f:    $(SRC)/pm_gmopts.F
pm_gmopts.o:    pm_gmopts.f $(SRC)/system.h $(SRC)/ions.inc \
                $(SRC)/elct.inc $(SRC)/pslo.inc $(SRC)/nlps.inc \
                $(SRC)/atwf.inc $(SRC)/kpts.inc $(SRC)/kpnt.inc \
                $(SRC)/str2.inc $(SRC)/spin.inc $(SRC)/linres.inc \
                $(SRC)/coor.inc $(SRC)/filn.inc $(SRC)/store.inc \
                $(SRC)/pimd.inc

pm_init.f:      $(SRC)/pm_init.F
pm_init.o:      pm_init.f $(SRC)/system.h $(SRC)/pimd.inc $(SRC)/ions.inc \
                $(SRC)/rmas.inc $(SRC)/cnst.inc $(DEST)/irat.inc \
                $(SRC)/adat.inc $(SRC)/fileopen.inc $(SRC)/cotr.inc

pm_mdpt.f:      $(SRC)/pm_mdpt.F
pm_mdpt.o:      pm_mdpt.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/nlps.inc $(SRC)/atwf.inc \
                $(SRC)/kpts.inc $(SRC)/str2.inc $(SRC)/clas.inc \
                $(SRC)/ddip.inc $(SRC)/linres.inc $(SRC)/bsym.inc \
                $(SRC)/shop.inc $(SRC)/mm_dim.inc $(SRC)/printp.inc \
                $(SRC)/coor.inc $(SRC)/filn.inc $(SRC)/store.inc \
                $(SRC)/cotr.inc $(SRC)/pimd.inc $(SRC)/fileopen.inc \
                $(SRC)/soft.inc $(SRC)/mfep.inc $(SRC)/cnst.inc

pm_wf.f:        $(SRC)/pm_wf.F
pm_wf.o:        pm_wf.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/ions.inc \
                $(SRC)/coor.inc $(SRC)/pimd.inc $(SRC)/filn.inc \
                $(SRC)/store.inc

pnosmove.f:     $(SRC)/pnosmove.F
pnosmove.o:     pnosmove.f $(SRC)/system.h $(SRC)/nose.inc \
                $(SRC)/ions.inc $(SRC)/cnst.inc

polarise.f:     $(SRC)/polarise.F
polarise.o:     polarise.f $(SRC)/system.h $(SRC)/cnst.inc \
                $(SRC)/cppt.inc $(SRC)/kpts.inc $(SRC)/kpnt.inc \
                $(SRC)/pola.inc $(SRC)/fft.inc $(SRC)/ions.inc \
                $(SRC)/spin.inc $(SRC)/atimes.inc $(SRC)/sfac.inc \
                $(SRC)/geq0.inc

posupa.f:       $(SRC)/posupa.F
posupa.o:       posupa.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/tpar.inc \
                $(SRC)/ions.inc $(SRC)/ropt.inc $(SRC)/harm.inc \
                $(SRC)/cotr.inc $(SRC)/cppt.inc $(SRC)/pslo.inc \
                $(SRC)/nort.inc $(SRC)/nlcc.inc $(SRC)/kpts.inc

posupi.f:       $(SRC)/posupi.F
posupi.o:       posupi.f $(SRC)/system.h $(SRC)/tpar.inc $(SRC)/ions.inc \
                $(SRC)/metr.inc $(SRC)/cnst.inc $(SRC)/store.inc \
                $(SRC)/fileopen.inc

potfor.f:       $(SRC)/potfor.F
potfor.o:       potfor.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cnst.inc \
                $(SRC)/cppt.inc $(SRC)/geq0.inc $(SRC)/sfac.inc

potmed.f:       $(SRC)/potmed.F
potmed.o:       potmed.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/atwf.inc \
                $(SRC)/qspl.inc $(SRC)/metr.inc $(SRC)/adat.inc

ppener.f:       $(SRC)/ppener.F
ppener.o:       ppener.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/cppt.inc \
                $(SRC)/geq0.inc $(SRC)/fft.inc $(SRC)/simul.inc

prcnosmove.f:   $(SRC)/prcnosmove.F
prcnosmove.o:   prcnosmove.f $(SRC)/system.h $(SRC)/nose.inc \
                $(SRC)/ions.inc $(SRC)/rmas.inc $(SRC)/cnst.inc \
                $(SRC)/metr.inc

prcpmd.f:       $(SRC)/prcpmd.F
prcpmd.o:       prcpmd.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/ener.inc \
                $(SRC)/elct.inc $(SRC)/tpar.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/soft.inc $(SRC)/nose.inc \
                $(SRC)/norm.inc $(SRC)/ropt.inc $(SRC)/cppt.inc \
                $(SRC)/coor.inc $(SRC)/geq0.inc $(SRC)/spin.inc \
                $(DEST)/irat.inc $(SRC)/nlcc.inc $(SRC)/strs.inc \
                $(SRC)/str2.inc $(SRC)/metr.inc $(SRC)/cotr.inc \
                $(SRC)/prcp.inc $(SRC)/store.inc $(SRC)/kpts.inc \
                $(SRC)/comvel.inc $(SRC)/cnst_dyn.inc $(SRC)/fileopen.inc

printave.f:     $(SRC)/printave.F
printave.o:     printave.f $(SRC)/system.h

printfor.f:     $(SRC)/printfor.F
printfor.o:     printfor.f $(SRC)/system.h $(SRC)/ions.inc \
                $(SRC)/cnst.inc $(SRC)/movi.inc $(SRC)/cotr.inc \
                $(SRC)/ropt.inc $(SRC)/metr.inc $(SRC)/strs.inc \
                $(SRC)/rmas.inc $(SRC)/prcp.inc $(SRC)/ddip.inc \
                $(SRC)/clas.inc $(SRC)/store.inc $(SRC)/adat.inc \
                $(SRC)/cnst_dyn.inc $(SRC)/fileopen.inc

printp.f:       $(SRC)/printp.F
printp.o:       printp.f $(SRC)/system.h $(DEST)/irat.inc $(SRC)/ions.inc \
                $(SRC)/cnst.inc $(SRC)/movi.inc $(SRC)/cotr.inc \
                $(SRC)/ropt.inc $(SRC)/metr.inc $(SRC)/strs.inc \
                $(SRC)/rmas.inc $(SRC)/prcp.inc $(SRC)/ddip.inc \
                $(SRC)/clas.inc $(SRC)/store.inc $(SRC)/adat.inc \
                $(SRC)/cell.inc $(SRC)/cnst_dyn.inc $(SRC)/fileopen.inc \
                $(SRC)/printp.inc $(SRC)/mm_dim.inc

prmem.f:        $(SRC)/prmem.F
prmem.o:        prmem.f $(SRC)/envj.inc

proja.f:        $(SRC)/proja.F
proja.o:        proja.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/norm.inc \
                $(SRC)/pslo.inc

proppt.f:       $(SRC)/proppt.F
proppt.o:       proppt.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/elct.inc \
                $(SRC)/coor.inc $(SRC)/prop.inc $(SRC)/soft.inc \
                $(SRC)/nlps.inc $(SRC)/sfac.inc $(SRC)/ions.inc \
                $(SRC)/pslo.inc $(SRC)/lodp.inc $(SRC)/ener.inc \
                $(SRC)/atwf.inc $(SRC)/condu.inc $(SRC)/pola.inc \
                $(SRC)/kpts.inc $(SRC)/poin.inc $(SRC)/store.inc \
                $(SRC)/isos.inc $(SRC)/geq0.inc $(DEST)/irat.inc \
                $(SRC)/fft.inc $(SRC)/cppt.inc $(SRC)/ldos.inc \
                $(SRC)/tpar.inc $(SRC)/norm.inc $(SRC)/ropt.inc \
                $(SRC)/ddip.inc $(SRC)/wann.inc $(SRC)/g_loc.inc \
                $(SRC)/cores.inc $(SRC)/fileopen.inc $(SRC)/mm_dim.inc \
                $(SRC)/cnst.inc $(SRC)/adat.inc $(SRC)/dipo.inc

prowfn.f:       $(SRC)/prowfn.F
prowfn.o:       prowfn.f $(SRC)/system.h $(SRC)/atom.inc $(SRC)/ener.inc \
                $(SRC)/elct.inc $(SRC)/spin.inc $(SRC)/adat.inc \
                $(SRC)/ions.inc $(SRC)/pslo.inc $(SRC)/atwf.inc \
                $(SRC)/sfac.inc $(DEST)/irat.inc $(SRC)/prop.inc \
                $(SRC)/prden.inc $(SRC)/fileopen.inc

prpcmove.f:     $(SRC)/prpcmove.F
prpcmove.o:     prpcmove.f $(SRC)/system.h $(SRC)/nose.inc \
                $(SRC)/ions.inc $(SRC)/rmas.inc $(SRC)/cnst.inc \
                $(SRC)/metr.inc

prpcnosmove.f:  $(SRC)/prpcnosmove.F
prpcnosmove.o:  prpcnosmove.f $(SRC)/system.h $(SRC)/nose.inc \
                $(SRC)/ions.inc $(SRC)/rmas.inc $(SRC)/cnst.inc \
                $(SRC)/metr.inc

prpnosmove.f:   $(SRC)/prpnosmove.F
prpnosmove.o:   prpnosmove.f $(SRC)/system.h $(SRC)/nose.inc \
                $(SRC)/ions.inc $(SRC)/rmas.inc $(SRC)/cnst.inc \
                $(SRC)/metr.inc

prpt.f:         $(SRC)/prpt.F
prpt.o:         prpt.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/nlps.inc $(SRC)/atwf.inc \
                $(SRC)/ddip.inc

prtgyr.f:       $(SRC)/prtgyr.F
prtgyr.o:       prtgyr.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/adat.inc \
                $(SRC)/cnst.inc $(SRC)/pimd.inc

ptheory.f:      $(SRC)/ptheory.F
ptheory.o:      ptheory.f $(SRC)/system.h $(SRC)/nlps.inc $(SRC)/fint.inc \
                $(SRC)/kpts.inc

purge.f:        $(SRC)/purge.F
purge.o:        purge.f $(SRC)/system.h $(SRC)/tpar.inc $(SRC)/ions.inc \
                $(SRC)/cotr.inc

putbet.f:       $(SRC)/putbet.F
putbet.o:       putbet.f $(SRC)/system.h $(SRC)/cppt.inc $(SRC)/ions.inc \
                $(SRC)/nlps.inc $(SRC)/pslo.inc $(SRC)/vdbp.inc \
                $(SRC)/dpot.inc $(SRC)/qspl.inc $(SRC)/strs.inc \
                $(SRC)/str2.inc $(SRC)/sgpp.inc $(SRC)/kpts.inc \
                $(SRC)/kpnt.inc $(SRC)/geq0.inc

puttau.f:       $(SRC)/puttau.F
puttau.o:       puttau.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cotr.inc

qrada_s.f:      $(SRC)/qrada_s.F
qrada_s.o:      qrada_s.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/pslo.inc \
                $(SRC)/vdbp.inc $(SRC)/cvan.inc $(SRC)/aavan.inc \
                $(SRC)/cnst.inc $(SRC)/nlps.inc $(SRC)/cppt.inc \
                $(SRC)/strs.inc $(SRC)/str2.inc $(SRC)/geq0.inc \
                $(SRC)/qspl.inc $(SRC)/gvec.inc

quenbo.f:       $(SRC)/quenbo.F
quenbo.o:       quenbo.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/ener.inc \
                $(SRC)/elct.inc $(SRC)/tpar.inc $(SRC)/pslo.inc \
                $(SRC)/norm.inc $(SRC)/ropt.inc $(SRC)/cppt.inc \
                $(SRC)/coor.inc $(SRC)/nlcc.inc $(SRC)/mm_input.inc \
                $(DEST)/irat.inc

qvan1.f:        $(SRC)/qvan1.F
qvan1.o:        qvan1.f $(SRC)/system.h $(SRC)/nlps.inc $(SRC)/ions.inc \
                $(SRC)/cvan.inc $(SRC)/cnst.inc $(SRC)/cppt.inc \
                $(SRC)/qspl.inc $(SRC)/aavan.inc

qvan2.f:        $(SRC)/qvan2.F
qvan2.o:        qvan2.f $(SRC)/system.h $(SRC)/nlps.inc $(SRC)/ions.inc \
                $(SRC)/cvan.inc $(SRC)/cppt.inc $(SRC)/aavan.inc \
                $(SRC)/qspl.inc

radin.f:        $(SRC)/radin.F
radin.o:        radin.f

raman_p.f:      $(SRC)/raman_p.F
raman_p.o:      raman_p.f $(SRC)/system.h $(DEST)/irat.inc \
                $(SRC)/dipo.inc $(SRC)/rmas.inc $(SRC)/cnst.inc \
                $(SRC)/gvec.inc $(SRC)/geq0.inc $(SRC)/prop.inc \
                $(SRC)/metr.inc $(SRC)/ddip.inc $(SRC)/fft.inc \
                $(SRC)/ions.inc $(SRC)/adat.inc $(SRC)/elct.inc \
                $(SRC)/kpnt.inc $(SRC)/nlps.inc $(SRC)/sfac.inc \
                $(SRC)/response_p.inc $(SRC)/fileopen.inc

ranc.f:         $(SRC)/ranc.F
ranc.o:         ranc.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/metr.inc

ranp.f:         $(SRC)/ranp.F
ranp.o:         ranp.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cotr.inc

ratom.f:        $(SRC)/ratom.F
ratom.o:        ratom.f $(SRC)/system.h $(SRC)/coor.inc $(SRC)/dpot.inc \
                $(SRC)/atom.inc $(SRC)/elct.inc $(SRC)/ions.inc \
                $(SRC)/nlps.inc $(SRC)/rmas.inc $(SRC)/cotr.inc \
                $(SRC)/movi.inc $(SRC)/nlcc.inc $(SRC)/ragg.inc \
                $(SRC)/pslo.inc $(SRC)/symm.inc $(DEST)/irat.inc \
                $(SRC)/clas.inc $(SRC)/atwf.inc $(SRC)/mm_input.inc \
                $(SRC)/mm_dim.inc $(SRC)/cnst_dyn.inc $(SRC)/adat.inc

rattle.f:       $(SRC)/rattle.F
rattle.o:       rattle.f $(SRC)/system.h $(SRC)/tpar.inc $(SRC)/ions.inc \
                $(SRC)/cotr.inc $(SRC)/mm_dim.inc

rbfgs.f:        $(SRC)/rbfgs.F
rbfgs.o:        rbfgs.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/tpar.inc \
                $(SRC)/isos.inc $(SRC)/cotr.inc

readff.f:       $(SRC)/readff.F
readff.o:       readff.f $(SRC)/system.h $(SRC)/clas.inc

readsr.f:       $(SRC)/readsr.F
readsr.o:       readsr.f

readvan.f:      $(SRC)/readvan.F
readvan.o:      readvan.f $(SRC)/system.h $(SRC)/atom.inc $(SRC)/pslo.inc \
                $(SRC)/vdbp.inc $(SRC)/ions.inc $(SRC)/vdbt.inc

recips.f:       $(SRC)/recips.F
recips.o:       recips.f

recpnew.f:      $(SRC)/recpnew.F
recpnew.o:      recpnew.f $(SRC)/system.h $(SRC)/atom.inc $(SRC)/adat.inc \
                $(SRC)/cnst.inc $(SRC)/ions.inc $(SRC)/ragg.inc \
                $(SRC)/dpot.inc $(SRC)/pslo.inc $(SRC)/rmas.inc \
                $(SRC)/func.inc $(SRC)/nlcc.inc $(SRC)/nlps.inc \
                $(SRC)/vdbt.inc $(SRC)/vdbp.inc $(SRC)/sgpp.inc

recpupf.f:      $(SRC)/recpupf.F
recpupf.o:      recpupf.f $(SRC)/system.h $(SRC)/atom.inc $(SRC)/adat.inc \
                $(SRC)/cnst.inc $(SRC)/ions.inc $(SRC)/ragg.inc \
                $(SRC)/dpot.inc $(SRC)/pslo.inc $(SRC)/rmas.inc \
                $(SRC)/func.inc $(SRC)/nlcc.inc $(SRC)/nlps.inc \
                $(SRC)/vdbt.inc $(SRC)/vdbp.inc $(SRC)/sgpp.inc

reigs.f:        $(SRC)/reigs.F
reigs.o:        reigs.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/spin.inc \
                $(SRC)/ropt.inc

rekine.f:       $(SRC)/rekine.F
rekine.o:       rekine.f $(SRC)/system.h $(SRC)/harm.inc $(SRC)/geq0.inc

repgen.f:       $(SRC)/repgen.F
repgen.o:       repgen.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cnst.inc \
                $(SRC)/adat.inc $(SRC)/pimd.inc $(SRC)/movi.inc \
                $(SRC)/isos.inc $(SRC)/store.inc $(SRC)/fileopen.inc

resetac.f:      $(SRC)/resetac.F
resetac.o:      resetac.f $(SRC)/system.h

respin_p.f:     $(SRC)/respin_p.F
respin_p.o:     respin_p.f $(SRC)/system.h $(DEST)/irat.inc \
                $(SRC)/store.inc $(SRC)/elct.inc $(SRC)/ions.inc \
                $(SRC)/response_p.inc $(SRC)/kpts.inc $(SRC)/kpnt.inc

response_p.f:   $(SRC)/response_p.F
response_p.o:   response_p.f $(SRC)/system.h $(SRC)/soft.inc \
                $(SRC)/elct.inc $(SRC)/coor.inc $(SRC)/kpts.inc \
                $(SRC)/ropt.inc $(SRC)/filn.inc $(SRC)/store.inc \
                $(SRC)/response_p.inc

restart_p.f:    $(SRC)/restart_p.F
restart_p.o:    restart_p.f $(SRC)/system.h $(SRC)/coor.inc \
                $(DEST)/irat.inc $(SRC)/response_p.inc $(SRC)/fileopen.inc

rgdiis.f:       $(SRC)/rgdiis.F
rgdiis.o:       rgdiis.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/tpar.inc \
                $(SRC)/isos.inc $(SRC)/cotr.inc

rggen.f:        $(SRC)/rggen.F
rggen.o:        rggen.f $(SRC)/system.h $(SRC)/gvec.inc $(SRC)/elct.inc \
                $(DEST)/irat.inc $(SRC)/cppt.inc $(SRC)/cell.inc \
                $(SRC)/metr.inc $(SRC)/sphe.inc $(SRC)/andr.inc \
                $(SRC)/broy.inc $(SRC)/fileopen.inc

rgmopt.f:       $(SRC)/rgmopt.F
rgmopt.o:       rgmopt.f $(SRC)/system.h $(SRC)/atwf.inc $(SRC)/spin.inc \
                $(SRC)/ener.inc $(SRC)/cnst.inc $(SRC)/nose.inc \
                $(SRC)/elct.inc $(SRC)/tpar.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/soft.inc $(SRC)/norm.inc \
                $(SRC)/ropt.inc $(SRC)/cppt.inc $(SRC)/coor.inc \
                $(SRC)/sfac.inc $(SRC)/cotr.inc $(SRC)/strs.inc \
                $(SRC)/nlcc.inc $(SRC)/andr.inc $(SRC)/andp.inc \
                $(SRC)/nlps.inc $(SRC)/fint.inc $(SRC)/poin.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/store.inc \
                $(SRC)/metr.inc $(SRC)/symm.inc $(SRC)/xinr.inc \
                $(SRC)/response_p.inc $(SRC)/fft.inc $(SRC)/implhv.inc \
                $(DEST)/irat.inc $(SRC)/linres.inc $(SRC)/bsym.inc \
                $(SRC)/bsympnt.inc $(SRC)/efld.inc $(SRC)/mm_dim.inc \
                $(SRC)/mm_input.inc $(SRC)/lscal.inc

rgs.f:          $(SRC)/rgs.F
rgs.o:          rgs.f $(SRC)/system.h $(SRC)/geq0.inc

rgsvan.f:       $(SRC)/rgsvan.F
rgsvan.o:       rgsvan.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/pslo.inc \
                $(SRC)/nlps.inc $(SRC)/sfac.inc

rho1ofr.f:      $(SRC)/rho1ofr.F
rho1ofr.o:      rho1ofr.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/cnst.inc \
                $(SRC)/geq0.inc $(SRC)/pslo.inc $(SRC)/ener.inc \
                $(SRC)/cppt.inc $(SRC)/sfac.inc $(SRC)/fft.inc \
                $(SRC)/rswf.inc $(SRC)/ions.inc $(SRC)/prcp.inc \
                $(SRC)/ropt.inc $(SRC)/symm.inc

rho1pri.f:      $(SRC)/rho1pri.F
rho1pri.o:      rho1pri.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/ions.inc \
                $(SRC)/elct.inc $(SRC)/cppt.inc

rhodiis.f:      $(SRC)/rhodiis.F
rhodiis.o:      rhodiis.f $(SRC)/andr.inc

rhoofr_c.f:     $(SRC)/rhoofr_c.F
rhoofr_c.o:     rhoofr_c.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/elct.inc $(SRC)/cnst.inc $(SRC)/geq0.inc \
                $(SRC)/pslo.inc $(SRC)/ener.inc $(SRC)/cppt.inc \
                $(SRC)/sfac.inc $(SRC)/fft.inc $(SRC)/rswf.inc \
                $(SRC)/ions.inc $(SRC)/prcp.inc $(SRC)/ropt.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/symm.inc

rhoofr.f:       $(SRC)/rhoofr.F
rhoofr.o:       rhoofr.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/elct.inc \
                $(SRC)/cnst.inc $(SRC)/geq0.inc $(SRC)/pslo.inc \
                $(SRC)/ener.inc $(SRC)/cppt.inc $(SRC)/sfac.inc \
                $(SRC)/fft.inc $(SRC)/rswf.inc $(SRC)/ions.inc \
                $(SRC)/prcp.inc $(SRC)/ropt.inc $(SRC)/symm.inc \
                $(SRC)/dg.inc

rhoofr_kdp.f:   $(SRC)/rhoofr_kdp.F
rhoofr_kdp.o:   rhoofr_kdp.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/elct.inc $(SRC)/cnst.inc $(SRC)/geq0.inc \
                $(SRC)/pslo.inc $(SRC)/ener.inc $(SRC)/cppt.inc \
                $(SRC)/sfac.inc $(SRC)/fft.inc $(SRC)/ions.inc \
                $(SRC)/prcp.inc $(SRC)/ropt.inc $(SRC)/symm.inc

rhoofr_p.f:     $(SRC)/rhoofr_p.F
rhoofr_p.o:     rhoofr_p.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/elct.inc $(SRC)/cnst.inc $(SRC)/geq0.inc \
                $(SRC)/pslo.inc $(SRC)/ener.inc $(SRC)/nlps.inc \
                $(SRC)/cppt.inc $(SRC)/sfac.inc $(SRC)/fft.inc \
                $(SRC)/rswf.inc $(SRC)/ions.inc $(SRC)/prcp.inc \
                $(SRC)/response_p.inc $(SRC)/ropt.inc

rhopri.f:       $(SRC)/rhopri.F
rhopri.o:       rhopri.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/ions.inc \
                $(SRC)/ropt.inc $(SRC)/cppt.inc $(SRC)/ener.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/prden.inc \
                $(SRC)/pimd.inc $(SRC)/bsym.inc $(SRC)/response_p.inc \
                $(SRC)/store.inc

rhov1.f:        $(SRC)/rhov1.F
rhov1.o:        rhov1.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/pslo.inc \
                $(SRC)/nlps.inc $(SRC)/elct.inc $(SRC)/cppt.inc \
                $(SRC)/sfac.inc $(SRC)/fft.inc $(SRC)/geq0.inc

rhov.f:         $(SRC)/rhov.F
rhov.o:         rhov.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/pslo.inc \
                $(SRC)/nlps.inc $(SRC)/elct.inc $(SRC)/cppt.inc \
                $(SRC)/sfac.inc $(SRC)/fft.inc $(SRC)/geq0.inc

rinforce.f:     $(SRC)/rinforce.F
rinforce.o:     rinforce.f $(SRC)/system.h $(SRC)/atom.inc \
                $(SRC)/spin.inc $(SRC)/ions.inc $(SRC)/pslo.inc \
                $(SRC)/vdbp.inc $(SRC)/cvan.inc $(SRC)/ener.inc \
                $(SRC)/ragg.inc $(SRC)/cnst.inc $(SRC)/cppt.inc \
                $(SRC)/nlcc.inc $(SRC)/geq0.inc $(SRC)/dpot.inc \
                $(DEST)/irat.inc $(SRC)/qspl.inc $(SRC)/str2.inc \
                $(SRC)/sgpp.inc $(SRC)/aavan.inc $(SRC)/kpts.inc \
                $(SRC)/nlps.inc $(SRC)/fint.inc $(SRC)/elct.inc \
                $(SRC)/isos.inc $(SRC)/eam.inc $(SRC)/mm_ion_dens.inc \
                $(SRC)/mm_input.inc $(SRC)/kpnt.inc $(SRC)/sphe.inc \
                $(SRC)/gvec.inc

rinforce_nuc.f: $(SRC)/rinforce_nuc.F
rinforce_nuc.o: rinforce_nuc.f $(SRC)/system.h $(SRC)/atom.inc \
                $(SRC)/spin.inc $(SRC)/ions.inc $(SRC)/pslo.inc \
                $(SRC)/vdbp.inc $(SRC)/cvan.inc $(SRC)/ener.inc \
                $(SRC)/ragg.inc $(SRC)/cnst.inc $(SRC)/cppt.inc \
                $(SRC)/nlcc.inc $(SRC)/nlps.inc $(SRC)/geq0.inc \
                $(SRC)/dpot.inc $(DEST)/irat.inc $(SRC)/qspl.inc \
                $(SRC)/str2.inc $(SRC)/sgpp.inc $(SRC)/aavan.inc \
                $(SRC)/kpts.inc $(SRC)/fint.inc $(SRC)/eam.inc \
                $(SRC)/mm_ion_dens.inc $(SRC)/mm_input.inc

rinit.f:        $(SRC)/rinit.F
rinit.o:        rinit.f $(SRC)/system.h $(SRC)/gvec.inc $(SRC)/cell.inc \
                $(SRC)/isos.inc $(SRC)/ions.inc $(SRC)/symm.inc \
                $(SRC)/cnst.inc $(SRC)/prcp.inc $(SRC)/metr.inc \
                $(SRC)/nlps.inc $(SRC)/fint.inc $(DEST)/irat.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/sphe.inc \
                $(SRC)/clas.inc $(SRC)/andr.inc $(SRC)/broy.inc \
                $(SRC)/elct.inc $(SRC)/kdpc.inc $(SRC)/store.inc \
                $(SRC)/response_p.inc

rinitwf.f:      $(SRC)/rinitwf.F
rinitwf.o:      rinitwf.f $(SRC)/system.h $(SRC)/kpts.inc $(SRC)/spin.inc \
                $(SRC)/mm_input.inc $(SRC)/pslo.inc $(SRC)/ropt.inc \
                $(SRC)/cppt.inc $(SRC)/ions.inc $(SRC)/nlcc.inc \
                $(SRC)/nlps.inc $(SRC)/tpar.inc $(SRC)/kpnt.inc \
                $(SRC)/sphe.inc $(SRC)/geq0.inc

rinvel.f:       $(SRC)/rinvel.F
rinvel.o:       rinvel.f $(SRC)/system.h $(SRC)/coor.inc $(SRC)/cnst.inc \
                $(SRC)/rmas.inc $(SRC)/ions.inc $(SRC)/nose.inc \
                $(SRC)/atwf.inc $(SRC)/cppt.inc $(SRC)/metr.inc \
                $(SRC)/cotr.inc $(SRC)/cnst_dyn.inc $(SRC)/mm_input.inc \
                $(SRC)/pimd.inc

rk4ov.f:        $(SRC)/rk4ov.F
rk4ov.o:        rk4ov.f $(SRC)/shop.inc $(SRC)/ropt.inc

rkpnt.f:        $(SRC)/rkpnt.F
rkpnt.o:        rkpnt.f $(SRC)/system.h $(DEST)/irat.inc $(SRC)/envj.inc \
                $(SRC)/elct.inc $(SRC)/gvec.inc $(SRC)/cppt.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/sphe.inc \
                $(SRC)/ions.inc $(SRC)/coor.inc $(SRC)/symm.inc \
                $(SRC)/fileopen.inc

rlbfgs.f:       $(SRC)/rlbfgs.F
rlbfgs.o:       rlbfgs.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/tpar.inc \
                $(SRC)/isos.inc $(SRC)/cotr.inc $(SRC)/store.inc \
                $(SRC)/lscal.inc $(DEST)/irat.inc

rnl_dk_p.f:     $(SRC)/rnl_dk_p.F
rnl_dk_p.o:     rnl_dk_p.f $(SRC)/system.h $(SRC)/pslo.inc \
                $(SRC)/nlps.inc $(SRC)/ions.inc $(SRC)/cppt.inc \
                $(SRC)/geq0.inc $(SRC)/kpts.inc $(SRC)/kpnt.inc \
                $(SRC)/response_p.inc

rnlfl.f:        $(SRC)/rnlfl.F
rnlfl.o:        rnlfl.f $(SRC)/system.h $(SRC)/nlps.inc $(SRC)/ions.inc \
                $(SRC)/pslo.inc $(SRC)/cvan.inc $(SRC)/sfac.inc \
                $(SRC)/cppt.inc

rnlfor.f:       $(SRC)/rnlfor.F
rnlfor.o:       rnlfor.f $(SRC)/system.h $(SRC)/nlps.inc $(SRC)/ions.inc \
                $(SRC)/pslo.inc $(SRC)/cvan.inc $(SRC)/cppt.inc \
                $(SRC)/spin.inc $(SRC)/sgpp.inc $(SRC)/sfac.inc

rnlin.f:        $(SRC)/rnlin.F
rnlin.o:        rnlin.f $(SRC)/system.h $(SRC)/sgpp.inc $(SRC)/pslo.inc \
                $(SRC)/qspl.inc $(SRC)/atom.inc $(SRC)/cnst.inc \
                $(SRC)/dpot.inc $(SRC)/nlps.inc $(SRC)/cppt.inc \
                $(SRC)/gvec.inc

rnlrh.f:        $(SRC)/rnlrh.F
rnlrh.o:        rnlrh.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/nlps.inc \
                $(SRC)/ions.inc $(SRC)/pslo.inc $(SRC)/cvan.inc \
                $(SRC)/cppt.inc $(SRC)/sgpp.inc $(SRC)/sfac.inc \
                $(SRC)/kpnt.inc $(SRC)/spin.inc $(SRC)/ener.inc

rnlset.f:       $(SRC)/rnlset.F
rnlset.o:       rnlset.f $(SRC)/system.h $(SRC)/atom.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/dpot.inc $(SRC)/nlps.inc \
                $(SRC)/sgpp.inc

rnlsm1.f:       $(SRC)/rnlsm1.F
rnlsm1.o:       rnlsm1.f $(SRC)/system.h $(SRC)/pslo.inc $(SRC)/nlps.inc \
                $(SRC)/vdbp.inc $(SRC)/ions.inc $(SRC)/cppt.inc \
                $(SRC)/sfac.inc $(SRC)/geq0.inc $(SRC)/kpts.inc \
                $(SRC)/kpnt.inc $(SRC)/mm_dim.inc

rnlsm_2d.f:     $(SRC)/rnlsm_2d.F
rnlsm_2d.o:     rnlsm_2d.f $(SRC)/system.h $(SRC)/nlps.inc \
                $(SRC)/ions.inc $(SRC)/sfac.inc $(SRC)/cppt.inc \
                $(SRC)/geq0.inc $(SRC)/pslo.inc

rnlsm2.f:       $(SRC)/rnlsm2.F
rnlsm2.o:       rnlsm2.f $(SRC)/system.h $(SRC)/nlps.inc $(SRC)/ions.inc \
                $(SRC)/sfac.inc $(SRC)/cppt.inc $(SRC)/geq0.inc \
                $(SRC)/pslo.inc $(SRC)/kpts.inc $(SRC)/kpnt.inc \
                $(SRC)/mm_dim.inc

rnlsmd.f:       $(SRC)/rnlsmd.F
rnlsmd.o:       rnlsmd.f $(SRC)/system.h $(SRC)/pslo.inc $(SRC)/nlps.inc \
                $(SRC)/vdbp.inc $(SRC)/ions.inc $(SRC)/cppt.inc \
                $(SRC)/sfac.inc $(SRC)/kpts.inc $(SRC)/mm_dim.inc \
                $(SRC)/geq0.inc

rnlsm.f:        $(SRC)/rnlsm.F
rnlsm.o:        rnlsm.f $(SRC)/system.h $(SRC)/nlps.inc

rnlsm_p.f:      $(SRC)/rnlsm_p.F
rnlsm_p.o:      rnlsm_p.f $(SRC)/system.h $(SRC)/nlps.inc $(SRC)/ions.inc \
                $(SRC)/cppt.inc $(SRC)/geq0.inc $(SRC)/pslo.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/sfac.inc

rortog.f:       $(SRC)/rortog.F
rortog.o:       rortog.f $(SRC)/system.h $(SRC)/tpar.inc $(SRC)/elct.inc \
                $(SRC)/spin.inc

rortv.f:        $(SRC)/rortv.F
rortv.o:        rortv.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/harm.inc \
                $(SRC)/cppt.inc $(SRC)/tpar.inc $(SRC)/nort.inc \
                $(SRC)/geq0.inc

rotate.f:       $(SRC)/rotate.F
rotate.o:       rotate.f $(SRC)/system.h $(SRC)/geq0.inc $(SRC)/spin.inc

rotate_my_wannier_manno_p.f:$(SRC)/rotate_my_wannier_manno_p.F
rotate_my_wannier_manno_p.o:rotate_my_wannier_manno_p.f $(SRC)/system.h \
                $(SRC)/cppt.inc $(SRC)/response_p.inc $(SRC)/ener.inc \
                $(DEST)/irat.inc $(SRC)/symm.inc $(SRC)/ions.inc \
                $(SRC)/metr.inc $(SRC)/fileopen.inc $(SRC)/cnst.inc \
                $(SRC)/coor.inc $(SRC)/gvec.inc $(SRC)/geq0.inc \
                $(SRC)/fft.inc $(SRC)/wann.inc $(SRC)/sfac.inc

rotate_my_wannier_para_p.f:$(SRC)/rotate_my_wannier_para_p.F
rotate_my_wannier_para_p.o:rotate_my_wannier_para_p.f $(SRC)/system.h \
                $(SRC)/cppt.inc $(SRC)/response_p.inc $(SRC)/ener.inc \
                $(DEST)/irat.inc $(SRC)/symm.inc $(SRC)/ions.inc \
                $(SRC)/metr.inc $(SRC)/geq0.inc $(SRC)/coor.inc \
                $(SRC)/fileopen.inc $(SRC)/cnst.inc $(SRC)/gvec.inc \
                $(SRC)/fft.inc $(SRC)/wann.inc $(SRC)/sfac.inc

rotate_my_wannier_p.f:$(SRC)/rotate_my_wannier_p.F
rotate_my_wannier_p.o:rotate_my_wannier_p.f $(SRC)/system.h \
                $(SRC)/cppt.inc $(SRC)/response_p.inc $(SRC)/ener.inc \
                $(DEST)/irat.inc $(SRC)/symm.inc $(SRC)/ions.inc \
                $(SRC)/metr.inc $(SRC)/fileopen.inc $(SRC)/cnst.inc \
                $(SRC)/coor.inc $(SRC)/gvec.inc $(SRC)/geq0.inc \
                $(SRC)/fft.inc $(SRC)/wann.inc $(SRC)/sfac.inc

rotvel.f:       $(SRC)/rotvel.F
rotvel.o:       rotvel.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/rmas.inc \
                $(SRC)/nose.inc $(SRC)/ions.inc $(SRC)/cotr.inc

rpiiint.f:      $(SRC)/rpiiint.F
rpiiint.o:      rpiiint.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cnst.inc \
                $(SRC)/ragg.inc $(SRC)/isos.inc $(SRC)/metr.inc \
                $(SRC)/eam.inc

rprfo.f:        $(SRC)/rprfo.F
rprfo.o:        rprfo.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/tpar.inc \
                $(SRC)/isos.inc $(SRC)/cotr.inc $(SRC)/store.inc \
                $(SRC)/lscal.inc $(SRC)/coor.inc

rrandd.f:       $(SRC)/rrandd.F
rrandd.o:       rrandd.f $(SRC)/system.h $(SRC)/spin.inc

rrane.f:        $(SRC)/rrane.F
rrane.o:        rrane.f $(SRC)/system.h $(SRC)/gvec.inc $(SRC)/cppt.inc \
                $(SRC)/geq0.inc $(SRC)/kpts.inc $(SRC)/kpnt.inc \
                $(SRC)/pslo.inc

rreadf.f:       $(SRC)/rreadf.F
rreadf.o:       rreadf.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cnst.inc \
                $(SRC)/pimd.inc $(SRC)/adat.inc $(SRC)/fileopen.inc

rrfo.f:         $(SRC)/rrfo.F
rrfo.o:         rrfo.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/tpar.inc \
                $(SRC)/cotr.inc

rscpot.f:       $(SRC)/rscpot.F
rscpot.o:       rscpot.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/spin.inc \
                $(SRC)/ener.inc $(SRC)/elct.inc $(SRC)/ropt.inc \
                $(SRC)/isos.inc $(SRC)/cppt.inc $(SRC)/pslo.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/prop.inc \
                $(SRC)/mm_input.inc $(SRC)/vdwc.inc $(SRC)/cnst_dyn.inc

rscve.f:        $(SRC)/rscve.F
rscve.o:        rscve.f $(SRC)/geq0.inc

rscvp.f:        $(SRC)/rscvp.F
rscvp.o:        rscvp.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cnst_dyn.inc

rtbis.f:        $(SRC)/rtbis.F
rtbis.o:        rtbis.f

rv30.f:         $(SRC)/rv30.F
rv30.o:         rv30.f $(SRC)/system.h $(SRC)/filn.inc $(SRC)/nose.inc \
                $(DEST)/irat.inc $(SRC)/store.inc $(SRC)/fileopen.inc \
                $(SRC)/geq0.inc $(SRC)/ions.inc $(SRC)/symm.inc \
                $(SRC)/elct.inc $(SRC)/ener.inc $(SRC)/metr.inc \
                $(SRC)/cell.inc $(SRC)/poin.inc $(SRC)/kpts.inc \
                $(SRC)/kpnt.inc $(SRC)/pimd.inc $(SRC)/clas.inc \
                $(SRC)/spin.inc $(SRC)/cotr.inc $(SRC)/lscal.inc \
                $(SRC)/bsym.inc $(SRC)/mm_dim.inc $(SRC)/mm_extrap.inc

rwfopt.f:       $(SRC)/rwfopt.F
rwfopt.o:       rwfopt.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/ener.inc \
                $(SRC)/elct.inc $(SRC)/tpar.inc $(SRC)/pslo.inc \
                $(SRC)/norm.inc $(SRC)/ropt.inc $(SRC)/cppt.inc \
                $(SRC)/sfac.inc $(SRC)/coor.inc $(SRC)/nlcc.inc \
                $(SRC)/ions.inc $(SRC)/andr.inc $(SRC)/andp.inc \
                $(SRC)/nlps.inc $(SRC)/fint.inc $(SRC)/cnst.inc \
                $(SRC)/poin.inc $(SRC)/kpts.inc $(SRC)/kpnt.inc \
                $(SRC)/fft.inc $(SRC)/store.inc $(SRC)/efld.inc \
                $(SRC)/mm_input.inc $(SRC)/mm_dim.inc $(SRC)/cplngs.inc \
                $(SRC)/lscal.inc $(SRC)/isos.inc $(SRC)/linres.inc

rwfopt_nuc.f:   $(SRC)/rwfopt_nuc.F
rwfopt_nuc.o:   rwfopt_nuc.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/ener.inc $(SRC)/elct.inc $(SRC)/tpar.inc \
                $(SRC)/pslo.inc $(SRC)/norm.inc $(SRC)/ropt.inc \
                $(SRC)/cppt.inc $(SRC)/sfac.inc $(SRC)/coor.inc \
                $(SRC)/nlcc.inc $(SRC)/ions.inc $(SRC)/andr.inc \
                $(SRC)/andp.inc $(SRC)/nlps.inc $(SRC)/fint.inc \
                $(SRC)/cnst.inc $(SRC)/poin.inc $(SRC)/kpts.inc \
                $(SRC)/kpnt.inc $(SRC)/fft.inc $(SRC)/store.inc \
                $(SRC)/efld.inc $(SRC)/mm_input.inc $(SRC)/mm_dim.inc

rwfopt_p.f:     $(SRC)/rwfopt_p.F
rwfopt_p.o:     rwfopt_p.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/ener.inc $(SRC)/elct.inc $(SRC)/tpar.inc \
                $(SRC)/pslo.inc $(SRC)/norm.inc $(SRC)/ropt.inc \
                $(SRC)/cppt.inc $(SRC)/sfac.inc $(SRC)/coor.inc \
                $(SRC)/nlcc.inc $(SRC)/ions.inc $(SRC)/andr.inc \
                $(SRC)/nlps.inc $(SRC)/fint.inc $(SRC)/cnst.inc \
                $(SRC)/poin.inc $(SRC)/kpts.inc $(SRC)/kpnt.inc \
                $(SRC)/fft.inc $(SRC)/str2.inc $(SRC)/store.inc \
                $(SRC)/response_p.inc $(SRC)/soft.inc

rw_linres.f:    $(SRC)/rw_linres.F
rw_linres.o:    rw_linres.f $(SRC)/system.h $(DEST)/irat.inc \
                $(SRC)/linres.inc

rwswap.f:       $(SRC)/rwswap.F
rwswap.o:       rwswap.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/cppt.inc \
                $(SRC)/ions.inc $(SRC)/nlps.inc $(SRC)/fint.inc \
                $(SRC)/swap.inc $(SRC)/kpts.inc $(SRC)/kpnt.inc \
                $(SRC)/sphe.inc $(SRC)/sfac.inc $(SRC)/envj.inc \
                $(DEST)/irat.inc

sample.f:       $(SRC)/sample.F
sample.o:       sample.f $(SRC)/system.h $(DEST)/irat.inc $(SRC)/filn.inc \
                $(SRC)/store.inc $(SRC)/fileopen.inc

saop.f:         $(SRC)/saop.F
saop.o:         saop.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/geq0.inc \
                $(SRC)/cppt.inc $(SRC)/cnst.inc $(SRC)/fft.inc

scratch.f:      $(SRC)/scratch.F
scratch.o:      scratch.f $(SRC)/scrp.inc

scslfft.f:      $(SRC)/scslfft.F
scslfft.o:      scslfft.f $(SRC)/system.h $(SRC)/fft.inc

sdcell.f:       $(SRC)/sdcell.F
sdcell.o:       sdcell.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/tpar.inc \
                $(SRC)/metr.inc $(SRC)/prcp.inc

sd_ii.f:        $(SRC)/sd_ii.F
sd_ii.o:        sd_ii.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cnst.inc \
                $(SRC)/ragg.inc $(SRC)/isos.inc $(SRC)/metr.inc

sdion.f:        $(SRC)/sdion.F
sdion.o:        sdion.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/tpar.inc \
                $(SRC)/isos.inc $(SRC)/cotr.inc $(SRC)/ener.inc

sdlinres.f:     $(SRC)/sdlinres.F
sdlinres.o:     sdlinres.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/geq0.inc $(SRC)/cnst.inc $(SRC)/ener.inc \
                $(SRC)/elct.inc $(SRC)/tpar.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/soft.inc $(SRC)/norm.inc \
                $(SRC)/ropt.inc $(SRC)/cppt.inc $(SRC)/coor.inc \
                $(SRC)/sfac.inc $(SRC)/cotr.inc $(SRC)/adat.inc \
                $(SRC)/rmas.inc $(SRC)/nlcc.inc $(SRC)/symm.inc \
                $(DEST)/irat.inc $(SRC)/nlps.inc $(SRC)/fint.inc \
                $(SRC)/poin.inc $(SRC)/kpts.inc $(SRC)/kpnt.inc \
                $(SRC)/isos.inc $(SRC)/store.inc $(SRC)/linres.inc \
                $(SRC)/fileopen.inc

sd_loc2.f:      $(SRC)/sd_loc2.F
sd_loc2.o:      sd_loc2.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cnst.inc \
                $(SRC)/cppt.inc $(SRC)/geq0.inc $(SRC)/sfac.inc

sd_loc.f:       $(SRC)/sd_loc.F
sd_loc.o:       sd_loc.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/cnst.inc \
                $(SRC)/cppt.inc $(SRC)/geq0.inc $(SRC)/sfac.inc

sd_nl2.f:       $(SRC)/sd_nl2.F
sd_nl2.o:       sd_nl2.f $(SRC)/system.h $(SRC)/nlps.inc $(SRC)/elct.inc \
                $(SRC)/ions.inc $(SRC)/pslo.inc $(SRC)/cvan.inc \
                $(SRC)/cppt.inc $(SRC)/spin.inc $(SRC)/sgpp.inc \
                $(SRC)/sfac.inc

sd_nl.f:        $(SRC)/sd_nl.F
sd_nl.o:        sd_nl.f $(SRC)/system.h $(SRC)/nlps.inc $(SRC)/ions.inc \
                $(SRC)/pslo.inc $(SRC)/cvan.inc $(SRC)/cppt.inc \
                $(SRC)/spin.inc $(SRC)/sgpp.inc

sd_wannier.f:   $(SRC)/sd_wannier.F
sd_wannier.o:   sd_wannier.f $(SRC)/system.h $(SRC)/wann.inc \
                $(SRC)/metr.inc

secder.f:       $(SRC)/secder.F
secder.o:       secder.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/spin.inc \
                $(SRC)/ener.inc $(SRC)/elct.inc $(SRC)/tpar.inc \
                $(SRC)/pslo.inc $(SRC)/ions.inc $(SRC)/soft.inc \
                $(SRC)/norm.inc $(SRC)/ropt.inc $(SRC)/cppt.inc \
                $(SRC)/coor.inc $(SRC)/sfac.inc $(SRC)/cotr.inc \
                $(SRC)/adat.inc $(SRC)/rmas.inc $(SRC)/nlcc.inc \
                $(SRC)/symm.inc $(DEST)/irat.inc $(SRC)/andr.inc \
                $(SRC)/andp.inc $(SRC)/nlps.inc $(SRC)/fint.inc \
                $(SRC)/poin.inc $(SRC)/kpts.inc $(SRC)/kpnt.inc \
                $(SRC)/store.inc $(SRC)/linres.inc $(SRC)/prop.inc \
                $(SRC)/dipo.inc $(SRC)/ddip.inc $(SRC)/fileopen.inc \
                $(SRC)/bsym.inc $(SRC)/bsympnt.inc $(SRC)/isos.inc \
                $(SRC)/cell.inc

secdpt.f:       $(SRC)/secdpt.F
secdpt.o:       secdpt.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/elct.inc \
                $(SRC)/pslo.inc $(SRC)/nlps.inc $(SRC)/atwf.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/linres.inc \
                $(SRC)/cotr.inc $(SRC)/prop.inc $(SRC)/bsym.inc

setbasis.f:     $(SRC)/setbasis.F
setbasis.o:     setbasis.f $(SRC)/system.h $(SRC)/atom.inc \
                $(SRC)/adat.inc $(SRC)/ions.inc $(SRC)/dpot.inc \
                $(SRC)/pslo.inc $(SRC)/atwf.inc $(SRC)/qspl.inc \
                $(DEST)/irat.inc $(SRC)/pimd.inc $(SRC)/response_p.inc \
                $(SRC)/cppt.inc $(SRC)/cnst.inc $(SRC)/gvec.inc \
                $(SRC)/sphe.inc $(SRC)/sfac.inc $(SRC)/geq0.inc

setbsstate.f:   $(SRC)/setbsstate.F
setbsstate.o:   setbsstate.f $(SRC)/system.h $(SRC)/bsym.inc \
                $(SRC)/elct.inc $(SRC)/ropt.inc $(SRC)/spin.inc \
                $(DEST)/irat.inc

setcnst.f:      $(SRC)/setcnst.F
setcnst.o:      setcnst.f $(SRC)/system.h $(SRC)/soft.inc $(SRC)/cnst.inc

setirec.f:      $(SRC)/setirec.F
setirec.o:      setirec.f $(SRC)/system.h $(SRC)/store.inc \
                $(SRC)/kpts.inc $(SRC)/clas.inc $(SRC)/nose.inc \
                $(DEST)/irat.inc $(SRC)/cotr.inc

setsc.f:        $(SRC)/setsc.F
setsc.o:        setsc.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/gvec.inc \
                $(SRC)/cell.inc $(SRC)/prcp.inc $(SRC)/metr.inc \
                $(SRC)/bc.inc $(SRC)/clas.inc $(DEST)/irat.inc \
                $(SRC)/isos.inc $(SRC)/symm.inc

setsys.f:       $(SRC)/setsys.F
setsys.o:       setsys.f $(SRC)/system.h $(SRC)/atom.inc $(SRC)/ions.inc \
                $(SRC)/ragg.inc $(SRC)/ropt.inc $(SRC)/dpot.inc \
                $(SRC)/pslo.inc $(SRC)/rmas.inc $(SRC)/elct.inc \
                $(SRC)/cnst.inc $(SRC)/cell.inc $(SRC)/vdbt.inc \
                $(SRC)/vdbp.inc $(SRC)/adat.inc $(DEST)/irat.inc \
                $(SRC)/coor.inc $(SRC)/geq0.inc $(SRC)/nose.inc \
                $(SRC)/cotr.inc $(SRC)/spin.inc $(SRC)/nlcc.inc \
                $(SRC)/isos.inc $(SRC)/filn.inc $(SRC)/sgpp.inc \
                $(SRC)/symm.inc $(SRC)/nlps.inc $(SRC)/fint.inc \
                $(SRC)/gvec.inc $(SRC)/sfac.inc $(SRC)/store.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/elct2.inc \
                $(SRC)/clas.inc $(SRC)/shop.inc $(SRC)/kdpc.inc \
                $(SRC)/shock.inc $(SRC)/sphe.inc $(SRC)/response_p.inc \
                $(SRC)/mm_input.inc $(SRC)/mm_dim.inc $(SRC)/eam.inc \
                $(SRC)/cnst_dyn.inc $(SRC)/metr.inc $(SRC)/bsym.inc \
                $(SRC)/wann.inc $(SRC)/mm_extrap.inc

shake.f:        $(SRC)/shake.F
shake.o:        shake.f $(SRC)/system.h $(SRC)/tpar.inc $(SRC)/ions.inc \
                $(SRC)/cotr.inc $(SRC)/mm_dim.inc

shop_adds.f:    $(SRC)/shop_adds.F
shop_adds.o:    shop_adds.f $(SRC)/system.h $(SRC)/shop.inc \
                $(SRC)/elct.inc $(SRC)/spin.inc $(SRC)/ener.inc \
                $(SRC)/sfac.inc $(SRC)/geq0.inc $(SRC)/coor.inc \
                $(SRC)/ropt.inc $(SRC)/ions.inc $(SRC)/fileopen.inc \
                $(DEST)/irat.inc

sh_tddft.f:     $(SRC)/sh_tddft.F
sh_tddft.o:     sh_tddft.f $(SRC)/system.h $(SRC)/cnst.inc \
                $(SRC)/spin.inc $(SRC)/linres.inc $(DEST)/irat.inc \
                $(SRC)/tpar.inc $(SRC)/elct.inc $(SRC)/isos.inc \
                $(SRC)/ropt.inc $(SRC)/geq0.inc $(SRC)/poin.inc \
                $(SRC)/ener.inc $(SRC)/norm.inc $(SRC)/cppt.inc \
                $(SRC)/soft.inc $(SRC)/nlps.inc $(SRC)/fint.inc \
                $(SRC)/conv.inc $(SRC)/ddip.inc $(SRC)/nlcc.inc \
                $(SRC)/tauf.inc $(SRC)/func.inc $(SRC)/store.inc \
                $(SRC)/kpts.inc

simple_model_p.f:$(SRC)/simple_model_p.F
simple_model_p.o:simple_model_p.f $(SRC)/system.h $(SRC)/response_p.inc \
                $(SRC)/prop.inc $(SRC)/cnst.inc $(SRC)/cppt.inc \
                $(SRC)/ddip.inc $(SRC)/isos.inc $(SRC)/wann.inc \
                $(SRC)/coor.inc $(SRC)/store.inc $(SRC)/ropt.inc \
                $(SRC)/sfac.inc $(SRC)/elct.inc $(SRC)/ener.inc \
                $(SRC)/fft.inc $(SRC)/atwf.inc $(SRC)/nlcc.inc \
                $(SRC)/kpnt.inc $(SRC)/tpar.inc $(SRC)/spin.inc \
                $(SRC)/linres.inc $(SRC)/geq0.inc $(SRC)/soft.inc \
                $(SRC)/fileopen.inc

softex.f:       $(SRC)/softex.F
softex.o:       softex.f $(SRC)/soft.inc

sort.f:         $(SRC)/sort.F
sort.o:         sort.f

specpt.f:       $(SRC)/specpt.F
specpt.o:       specpt.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/kpts.inc \
                $(SRC)/spin.inc $(SRC)/coor.inc $(SRC)/linres.inc \
                $(SRC)/mm_dim.inc $(SRC)/isos.inc $(SRC)/ropt.inc \
                $(SRC)/cnst.inc $(SRC)/geq0.inc $(SRC)/poin.inc \
                $(SRC)/ener.inc $(SRC)/norm.inc $(SRC)/cppt.inc \
                $(SRC)/soft.inc $(DEST)/irat.inc $(SRC)/nlps.inc \
                $(SRC)/fint.inc $(SRC)/conv.inc $(SRC)/ddip.inc \
                $(SRC)/nlcc.inc $(SRC)/tauf.inc $(SRC)/func.inc \
                $(SRC)/tpot.inc $(SRC)/mols.inc $(SRC)/store.inc \
                $(SRC)/efld.inc $(SRC)/mm_input.inc $(SRC)/ions.inc

spsi.f:         $(SRC)/spsi.F
spsi.o:         spsi.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/nlps.inc \
                $(SRC)/pslo.inc $(SRC)/cvan.inc $(SRC)/cppt.inc \
                $(SRC)/sfac.inc

ssic.f:         $(SRC)/ssic.F
ssic.o:         ssic.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/fft.inc \
                $(SRC)/cppt.inc $(SRC)/geq0.inc $(SRC)/spin.inc \
                $(DEST)/irat.inc

stagetrans.f:   $(SRC)/stagetrans.F
stagetrans.o:   stagetrans.f $(SRC)/system.h $(SRC)/ions.inc \
                $(SRC)/pimd.inc

startpa.f:      $(SRC)/startpa.F
startpa.o:      startpa.f $(SRC)/system.h $(SRC)/geq0.inc

stcop.f:        $(SRC)/stcop.F
stcop.o:        stcop.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/elct.inc \
                $(SRC)/linres.inc

stopgm.f:       $(SRC)/stopgm.F
stopgm.o:       stopgm.f $(SRC)/system.h

stress.f:       $(SRC)/stress.F
stress.o:       stress.f $(SRC)/system.h $(SRC)/prcp.inc $(SRC)/strs.inc \
                $(SRC)/str2.inc $(SRC)/ions.inc $(SRC)/cppt.inc \
                $(SRC)/pslo.inc $(SRC)/sfac.inc $(SRC)/cnst.inc \
                $(SRC)/ragg.inc $(SRC)/isos.inc $(SRC)/ropt.inc \
                $(SRC)/nlcc.inc $(SRC)/cvan.inc $(SRC)/qspl.inc \
                $(SRC)/fft.inc $(SRC)/metr.inc $(SRC)/kpnt.inc \
                $(SRC)/kpts.inc $(SRC)/sgpp.inc $(SRC)/symm.inc \
                $(SRC)/nlps.inc $(SRC)/fint.inc $(SRC)/kdpc.inc \
                $(SRC)/kdp.inc $(SRC)/vdwc.inc $(SRC)/elct.inc

struc.f:        $(SRC)/struc.F
struc.o:        struc.f $(SRC)/system.h $(SRC)/empf.inc $(SRC)/cnst.inc \
                $(SRC)/adat.inc $(SRC)/ions.inc $(SRC)/struc.inc \
                $(DEST)/irat.inc

sumfnl.f:       $(SRC)/sumfnl.F
sumfnl.o:       sumfnl.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/nlps.inc \
                $(SRC)/sfac.inc $(DEST)/irat.inc

summat.f:       $(SRC)/summat.F
summat.o:       summat.f $(SRC)/system.h $(SRC)/nlps.inc

symmetry.f:     $(SRC)/symmetry.F
symmetry.o:     symmetry.f

symtrz.f:       $(SRC)/symtrz.F
symtrz.o:       symtrz.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/symm.inc \
                $(SRC)/metr.inc $(SRC)/cppt.inc $(SRC)/symm4.inc \
                $(SRC)/cnst.inc $(SRC)/fft.inc $(DEST)/irat.inc \
                $(SRC)/gvec.inc $(SRC)/geq0.inc

sysdepend.o:    $(SRC)/sysdepend.c

sysin.f:        $(SRC)/sysin.F
sysin.o:        sysin.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/cell.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/isos.inc \
                $(SRC)/ropt.inc $(SRC)/spin.inc $(SRC)/ions.inc \
                $(SRC)/symm.inc $(SRC)/cnst.inc $(SRC)/prcp.inc \
                $(SRC)/gvec.inc $(DEST)/irat.inc $(SRC)/sphe.inc \
                $(SRC)/pslo.inc $(SRC)/store.inc $(SRC)/elct2.inc \
                $(SRC)/kdpc.inc $(SRC)/clas.inc $(SRC)/fcas.inc \
                $(SRC)/cplngs.inc $(SRC)/ddip.inc $(SRC)/hfx.inc \
                $(SRC)/shock.inc $(SRC)/dg.inc

t3dfft.f:       $(SRC)/t3dfft.F
t3dfft.o:       t3dfft.f $(SRC)/system.h $(SRC)/fft.inc

tauofr.f:       $(SRC)/tauofr.F
tauofr.o:       tauofr.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/fft.inc \
                $(SRC)/tauf.inc $(SRC)/elct.inc $(SRC)/pslo.inc \
                $(SRC)/cnst.inc $(SRC)/geq0.inc $(SRC)/cppt.inc

td_dav.f:       $(SRC)/td_dav.F
td_dav.o:       td_dav.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/tpar.inc \
                $(SRC)/soft.inc $(SRC)/norm.inc $(SRC)/ropt.inc \
                $(SRC)/geq0.inc $(SRC)/cppt.inc $(SRC)/cnst.inc \
                $(SRC)/linres.inc $(SRC)/spin.inc

td_force.f:     $(SRC)/td_force.F
td_force.o:     td_force.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/elct.inc $(SRC)/poin.inc $(SRC)/ions.inc \
                $(SRC)/ropt.inc $(SRC)/linres.inc $(SRC)/fft.inc \
                $(SRC)/cnst.inc $(SRC)/cppt.inc $(SRC)/geq0.inc \
                $(SRC)/sfac.inc $(SRC)/isos.inc

td_lanczos.f:   $(SRC)/td_lanczos.F
td_lanczos.o:   td_lanczos.f $(SRC)/system.h $(SRC)/elct.inc \
                $(SRC)/tpar.inc $(SRC)/soft.inc $(SRC)/norm.inc \
                $(SRC)/ropt.inc $(SRC)/geq0.inc $(SRC)/cnst.inc \
                $(SRC)/cppt.inc $(SRC)/linres.inc $(SRC)/spin.inc

td_mm_qmmm_forcedr.f:$(SRC)/td_mm_qmmm_forcedr.F
td_mm_qmmm_forcedr.o:td_mm_qmmm_forcedr.f $(SRC)/system.h $(SRC)/ener.inc \
                $(DEST)/irat.inc $(SRC)/ropt.inc $(SRC)/mm_input.inc \
                $(SRC)/mm_dim.inc

td_nhdav.f:     $(SRC)/td_nhdav.F
td_nhdav.o:     td_nhdav.f $(SRC)/system.h $(SRC)/elct.inc \
                $(SRC)/tpar.inc $(SRC)/soft.inc $(SRC)/norm.inc \
                $(SRC)/ropt.inc $(SRC)/geq0.inc $(SRC)/cppt.inc \
                $(SRC)/linres.inc $(SRC)/spin.inc

tdnlfor.f:      $(SRC)/tdnlfor.F
tdnlfor.o:      tdnlfor.f $(SRC)/system.h $(SRC)/nlps.inc $(SRC)/ions.inc \
                $(SRC)/pslo.inc $(SRC)/cvan.inc $(SRC)/cppt.inc \
                $(SRC)/spin.inc $(SRC)/sgpp.inc $(SRC)/sfac.inc

td_os_berry.f:  $(SRC)/td_os_berry.F
td_os_berry.o:  td_os_berry.f $(SRC)/system.h $(DEST)/irat.inc \
                $(SRC)/rmas.inc $(SRC)/cnst.inc $(SRC)/gvec.inc \
                $(SRC)/geq0.inc $(SRC)/prop.inc $(SRC)/metr.inc \
                $(SRC)/ddip.inc

td_os.f:        $(SRC)/td_os.F
td_os.o:        td_os.f $(SRC)/system.h $(DEST)/irat.inc $(SRC)/rmas.inc \
                $(SRC)/cnst.inc $(SRC)/gvec.inc $(SRC)/geq0.inc \
                $(SRC)/prop.inc $(SRC)/metr.inc $(SRC)/ddip.inc \
                $(SRC)/symm.inc $(SRC)/linres.inc

td_pcg.f:       $(SRC)/td_pcg.F
td_pcg.o:       td_pcg.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/tpar.inc \
                $(SRC)/soft.inc $(SRC)/norm.inc $(SRC)/ropt.inc \
                $(SRC)/geq0.inc $(SRC)/cppt.inc $(SRC)/cnst.inc \
                $(SRC)/linres.inc $(SRC)/spin.inc

td_prop.f:      $(SRC)/td_prop.F
td_prop.o:      td_prop.f $(SRC)/system.h $(SRC)/geq0.inc $(DEST)/irat.inc \
                $(SRC)/cppt.inc $(SRC)/ions.inc $(SRC)/isos.inc \
                $(SRC)/fft.inc $(SRC)/cnst.inc

td_rdiis.f:     $(SRC)/td_rdiis.F
td_rdiis.o:     td_rdiis.f $(SRC)/system.h $(SRC)/elct.inc \
                $(SRC)/tpar.inc $(SRC)/soft.inc $(SRC)/norm.inc \
                $(SRC)/ropt.inc $(SRC)/geq0.inc $(SRC)/cppt.inc \
                $(SRC)/cnst.inc $(SRC)/linres.inc $(SRC)/spin.inc

testex.f:       $(SRC)/testex.F
testex.o:       testex.f $(SRC)/system.h $(DEST)/irat.inc $(SRC)/pimd.inc

teststore.f:    $(SRC)/teststore.F
teststore.o:    teststore.f $(SRC)/system.h $(SRC)/store.inc

timec.f:        $(SRC)/timec.F
timec.o:        timec.f

timer.f:        $(SRC)/timer.F
timer.o:        timer.f $(SRC)/time.inc $(SRC)/envj.inc

timetag.f:      $(SRC)/timetag.F
timetag.o:      timetag.f

totstr.f:       $(SRC)/totstr.F
totstr.o:       totstr.f $(SRC)/system.h $(SRC)/strs.inc $(SRC)/metr.inc \
                $(SRC)/cnst.inc $(SRC)/prcp.inc $(SRC)/vdwc.inc \
                $(SRC)/shock.inc $(SRC)/cnst_dyn.inc

tst2min.f:      $(SRC)/tst2min.F
tst2min.o:      tst2min.f $(SRC)/system.h $(SRC)/cnst_dyn.inc \
                $(SRC)/soft.inc $(DEST)/irat.inc $(SRC)/fileopen.inc

tst2min_inp.f:  $(SRC)/tst2min_inp.F
tst2min_inp.o:  tst2min_inp.f $(SRC)/system.h $(SRC)/cotr.inc \
                $(SRC)/cnst_dyn.inc $(DEST)/irat.inc $(SRC)/store.inc \
                $(SRC)/ions.inc $(SRC)/mm_dim.inc $(SRC)/mm_input.inc

ttimp.f:        $(SRC)/ttimp.F
ttimp.o:        ttimp.f

up3_p.f:        $(SRC)/up3_p.F
up3_p.o:        up3_p.f $(SRC)/system.h $(SRC)/andp.inc $(SRC)/norm.inc \
                $(SRC)/ropt.inc $(SRC)/soft.inc $(SRC)/sfac.inc \
                $(SRC)/ener.inc $(SRC)/elct.inc $(SRC)/nlps.inc \
                $(SRC)/fint.inc $(SRC)/kpnt.inc $(SRC)/kpts.inc \
                $(SRC)/store.inc $(SRC)/elct2.inc $(DEST)/irat.inc \
                $(SRC)/ions.inc $(SRC)/pslo.inc $(SRC)/cnst.inc \
                $(SRC)/geq0.inc $(SRC)/cppt.inc $(SRC)/sphe.inc \
                $(SRC)/response_p.inc

updrho.f:       $(SRC)/updrho.F
updrho.o:       updrho.f $(SRC)/system.h $(SRC)/andr.inc $(SRC)/broy.inc \
                $(SRC)/andp.inc $(SRC)/norm.inc $(SRC)/ropt.inc \
                $(SRC)/soft.inc $(SRC)/ions.inc $(SRC)/sfac.inc \
                $(SRC)/pslo.inc $(SRC)/ener.inc $(SRC)/elct.inc \
                $(SRC)/nlps.inc $(SRC)/fint.inc $(SRC)/spin.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/store.inc \
                $(SRC)/elct2.inc $(SRC)/kdp.inc $(SRC)/kdpc.inc \
                $(SRC)/conv.inc $(DEST)/irat.inc $(SRC)/vdwc.inc \
                $(SRC)/tauf.inc $(SRC)/func.inc

updwf.f:        $(SRC)/updwf.F
updwf.o:        updwf.f $(SRC)/system.h $(SRC)/norm.inc $(SRC)/ions.inc \
                $(SRC)/ropt.inc $(SRC)/tpar.inc $(SRC)/soft.inc \
                $(SRC)/pslo.inc $(SRC)/cppt.inc $(SRC)/geq0.inc \
                $(SRC)/ener.inc $(SRC)/mm_input.inc $(SRC)/mm_dim.inc

updwf_p.f:      $(SRC)/updwf_p.F
updwf_p.o:      updwf_p.f $(SRC)/system.h $(SRC)/norm.inc $(SRC)/ions.inc \
                $(SRC)/ropt.inc $(SRC)/tpar.inc $(SRC)/soft.inc \
                $(SRC)/pslo.inc $(SRC)/cppt.inc $(SRC)/geq0.inc \
                $(SRC)/nlps.inc $(SRC)/elct.inc $(SRC)/response_p.inc

util.f:         $(SRC)/util.F
util.o:         util.f $(SRC)/geq0.inc $(SRC)/system.h

util_p.f:       $(SRC)/util_p.F
util_p.o:       util_p.f $(SRC)/system.h $(SRC)/cell.inc $(SRC)/gvec.inc \
                $(SRC)/ions.inc $(SRC)/coor.inc $(SRC)/cnst.inc \
                $(DEST)/irat.inc $(SRC)/metr.inc $(SRC)/response_p.inc \
                $(SRC)/fileopen.inc $(SRC)/cppt.inc $(SRC)/sfac.inc \
                $(SRC)/geq0.inc

u_upd_exp.f:    $(SRC)/u_upd_exp.F
u_upd_exp.o:    u_upd_exp.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/g_loc.inc

u_upd_exp_sum.f:$(SRC)/u_upd_exp_sum.F
u_upd_exp_sum.o:u_upd_exp_sum.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/g_loc.inc $(SRC)/wann.inc

u_upd_spread.f: $(SRC)/u_upd_spread.F
u_upd_spread.o: u_upd_spread.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/g_loc.inc

u_upd_spread_sum.f:$(SRC)/u_upd_spread_sum.F
u_upd_spread_sum.o:u_upd_spread_sum.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/g_loc.inc

v1ofrho1.f:     $(SRC)/v1ofrho1.F
v1ofrho1.o:     v1ofrho1.f $(SRC)/system.h $(SRC)/cnst.inc \
                $(SRC)/spin.inc $(SRC)/cppt.inc $(SRC)/geq0.inc \
                $(SRC)/fft.inc $(SRC)/isos.inc $(SRC)/poin.inc \
                $(SRC)/linres.inc $(SRC)/simul.inc

v1ofrho_p.f:    $(SRC)/v1ofrho_p.F
v1ofrho_p.o:    v1ofrho_p.f $(SRC)/system.h $(SRC)/cnst.inc \
                $(SRC)/spin.inc $(SRC)/cppt.inc $(SRC)/geq0.inc \
                $(SRC)/fft.inc $(SRC)/response_p.inc $(SRC)/simul.inc \
                $(SRC)/pslo.inc $(SRC)/nlcc.inc $(SRC)/isos.inc

v1xc_p.f:       $(SRC)/v1xc_p.F
v1xc_p.o:       v1xc_p.f $(SRC)/system.h $(SRC)/fft.inc $(SRC)/spin.inc \
                $(SRC)/response_p.inc $(SRC)/nlcc.inc $(SRC)/cppt.inc \
                $(SRC)/func.inc $(SRC)/cnst.inc

vbeta.f:        $(SRC)/vbeta.F
vbeta.o:        vbeta.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/pslo.inc \
                $(SRC)/ions.inc $(SRC)/cvan.inc $(SRC)/geq0.inc \
                $(SRC)/cppt.inc $(SRC)/nlps.inc $(SRC)/fint.inc \
                $(SRC)/sfac.inc $(SRC)/fft.inc $(SRC)/kpts.inc \
                $(SRC)/kpnt.inc

vdbinit.f:      $(SRC)/vdbinit.F
vdbinit.o:      vdbinit.f $(SRC)/system.h $(SRC)/pslo.inc $(SRC)/vdbp.inc \
                $(SRC)/ions.inc $(SRC)/cvan.inc $(SRC)/aavan.inc \
                $(SRC)/cnst.inc $(SRC)/cppt.inc $(SRC)/nlps.inc \
                $(SRC)/qspl.inc $(SRC)/gvec.inc $(DEST)/irat.inc

vdw.f:          $(SRC)/vdw.F
vdw.o:          vdw.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/strs.inc \
                $(SRC)/metr.inc

vdwin.f:        $(SRC)/vdwin.F
vdwin.o:        vdwin.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/adat.inc \
                $(SRC)/vdwc.inc $(DEST)/irat.inc $(SRC)/cnst.inc

velocitinp.f:   $(SRC)/velocitinp.F
velocitinp.o:   velocitinp.f $(SRC)/system.h $(SRC)/ions.inc \
                $(SRC)/coor.inc

velupa.f:       $(SRC)/velupa.F
velupa.o:       velupa.f $(SRC)/system.h $(SRC)/tpar.inc $(SRC)/ions.inc \
                $(SRC)/harm.inc $(SRC)/cppt.inc

velupi.f:       $(SRC)/velupi.F
velupi.o:       velupi.f $(SRC)/system.h $(SRC)/tpar.inc $(SRC)/ions.inc \
                $(SRC)/cnst.inc $(SRC)/rmas.inc $(SRC)/metr.inc \
                $(SRC)/prcp.inc $(SRC)/pimd.inc

vepsup.f:       $(SRC)/vepsup.F
vepsup.o:       vepsup.f $(SRC)/system.h $(SRC)/nose.inc $(SRC)/ions.inc \
                $(SRC)/rmas.inc $(SRC)/cnst.inc $(SRC)/metr.inc \
                $(SRC)/tpar.inc $(SRC)/shock.inc

vgsortho.f:     $(SRC)/vgsortho.F
vgsortho.o:     vgsortho.f $(SRC)/geq0.inc

vhk.f:          $(SRC)/vhk.F
vhk.o:          vhk.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/elct.inc \
                $(SRC)/cppt.inc $(SRC)/pslo.inc $(SRC)/fft.inc \
                $(SRC)/geq0.inc $(SRC)/nlcc.inc

vibana.f:       $(SRC)/vibana.F
vibana.o:       vibana.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/coor.inc \
                $(SRC)/cotr.inc $(SRC)/rmas.inc $(SRC)/symm.inc \
                $(SRC)/adat.inc $(SRC)/lscal.inc $(SRC)/spin.inc \
                $(SRC)/store.inc

vlocst.f:       $(SRC)/vlocst.F
vlocst.o:       vlocst.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/cppt.inc \
                $(SRC)/geq0.inc $(SRC)/pslo.inc $(SRC)/ions.inc \
                $(SRC)/strs.inc $(SRC)/str2.inc $(SRC)/ragg.inc \
                $(SRC)/fft.inc

vofrhoa.f:      $(SRC)/vofrhoa.F
vofrhoa.o:      vofrhoa.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/ener.inc \
                $(SRC)/ions.inc $(SRC)/simul.inc $(SRC)/sfac.inc \
                $(SRC)/cppt.inc $(SRC)/geq0.inc $(SRC)/fft.inc \
                $(SRC)/efld.inc $(SRC)/elct.inc $(SRC)/isos.inc

vofrhob.f:      $(SRC)/vofrhob.F
vofrhob.o:      vofrhob.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/ions.inc \
                $(SRC)/ener.inc $(SRC)/elct.inc $(SRC)/cppt.inc \
                $(SRC)/pslo.inc $(SRC)/simul.inc $(SRC)/fft.inc \
                $(SRC)/geq0.inc $(SRC)/cvan.inc $(SRC)/nlps.inc \
                $(SRC)/sfac.inc $(SRC)/nlcc.inc $(SRC)/strs.inc \
                $(SRC)/str2.inc $(SRC)/efld.inc $(SRC)/tauf.inc \
                $(SRC)/extpot.inc $(SRC)/isos.inc $(SRC)/tpot.inc \
                $(SRC)/linres.inc

vofrhoc.f:      $(SRC)/vofrhoc.F
vofrhoc.o:      vofrhoc.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/ener.inc \
                $(SRC)/ions.inc $(SRC)/simul.inc $(SRC)/sfac.inc \
                $(SRC)/cppt.inc $(SRC)/geq0.inc $(SRC)/fft.inc \
                $(SRC)/nlcc.inc $(SRC)/fcas.inc $(SRC)/elct.inc \
                $(SRC)/efld.inc $(SRC)/ropt.inc $(SRC)/spin.inc \
                $(SRC)/extpot.inc

vofrho.f:       $(SRC)/vofrho.F
vofrho.o:       vofrho.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/isos.inc \
                $(SRC)/store.inc $(SRC)/poin.inc $(SRC)/pslo.inc

vofrhoh.f:      $(SRC)/vofrhoh.F
vofrhoh.o:      vofrhoh.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/ener.inc \
                $(SRC)/isos.inc $(SRC)/ions.inc $(SRC)/simul.inc \
                $(SRC)/sfac.inc $(SRC)/cppt.inc $(SRC)/geq0.inc \
                $(SRC)/fft.inc $(SRC)/efld.inc $(SRC)/elct.inc

vofrhos.f:      $(SRC)/vofrhos.F
vofrhos.o:      vofrhos.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/ions.inc \
                $(SRC)/ener.inc $(SRC)/elct.inc $(SRC)/cppt.inc \
                $(SRC)/pslo.inc $(SRC)/simul.inc $(SRC)/fft.inc \
                $(SRC)/geq0.inc $(SRC)/cvan.inc $(SRC)/nlps.inc \
                $(SRC)/sfac.inc $(SRC)/nlcc.inc $(SRC)/strs.inc \
                $(SRC)/str2.inc $(SRC)/efld.inc $(SRC)/extpot.inc \
                $(SRC)/func.inc $(SRC)/isos.inc $(SRC)/cnst.inc

vofrhot.f:      $(SRC)/vofrhot.F
vofrhot.o:      vofrhot.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/ener.inc \
                $(SRC)/ions.inc $(SRC)/simul.inc $(SRC)/sfac.inc \
                $(SRC)/cppt.inc $(SRC)/geq0.inc $(SRC)/fft.inc \
                $(SRC)/efld.inc $(SRC)/elct.inc $(SRC)/isos.inc

vpsi.f:         $(SRC)/vpsi.F
vpsi.o:         vpsi.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/cppt.inc \
                $(SRC)/cnst.inc $(SRC)/geq0.inc $(SRC)/fft.inc \
                $(SRC)/rswf.inc $(SRC)/prcp.inc $(SRC)/kpts.inc \
                $(SRC)/kpnt.inc $(SRC)/ener.inc $(SRC)/dg.inc

vpsi_lse.f:     $(SRC)/vpsi_lse.F
vpsi_lse.o:     vpsi_lse.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/cppt.inc $(SRC)/cnst.inc $(SRC)/geq0.inc \
                $(SRC)/fft.inc $(SRC)/rswf.inc $(SRC)/prcp.inc \
                $(SRC)/ener.inc

vpsi_p.f:       $(SRC)/vpsi_p.F
vpsi_p.o:       vpsi_p.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/cppt.inc \
                $(SRC)/cnst.inc $(SRC)/geq0.inc $(SRC)/fft.inc \
                $(SRC)/prcp.inc $(SRC)/kpts.inc $(SRC)/kpnt.inc \
                $(SRC)/response_p.inc $(SRC)/elct.inc

vtaupsi.f:      $(SRC)/vtaupsi.F
vtaupsi.o:      vtaupsi.f $(SRC)/system.h $(SRC)/tauf.inc $(SRC)/fft.inc \
                $(SRC)/kpts.inc $(SRC)/spin.inc $(SRC)/cppt.inc

vtd2.f:         $(SRC)/vtd2.F
vtd2.o:         vtd2.f $(SRC)/system.h $(SRC)/spin.inc $(SRC)/func.inc \
                $(SRC)/poin.inc $(SRC)/fft.inc $(SRC)/linres.inc

wannier_center.f:$(SRC)/wannier_center.F
wannier_center.o:wannier_center.f $(SRC)/system.h $(SRC)/wann.inc \
                $(SRC)/metr.inc $(SRC)/store.inc $(SRC)/hfx.inc \
                $(DEST)/irat.inc $(SRC)/ions.inc $(SRC)/ropt.inc \
                $(SRC)/cnst.inc $(SRC)/adat.inc $(SRC)/response_p.inc \
                $(SRC)/fileopen.inc $(SRC)/mm_dim.inc

wannier.f:      $(SRC)/wannier.F
wannier.o:      wannier.f

wannier_print.f:$(SRC)/wannier_print.F
wannier_print.o:wannier_print.f $(SRC)/system.h $(SRC)/wann.inc \
                $(SRC)/fft.inc $(DEST)/irat.inc $(SRC)/cppt.inc

wc_dos.f:       $(SRC)/wc_dos.F
wc_dos.o:       wc_dos.f $(SRC)/system.h $(SRC)/geq0.inc $(SRC)/wann.inc \
                $(SRC)/spin.inc $(SRC)/fileopen.inc $(SRC)/cnst.inc

wfnio.f:        $(SRC)/wfnio.F
wfnio.o:        wfnio.f $(SRC)/system.h $(DEST)/irat.inc $(SRC)/spin.inc \
                $(SRC)/kpts.inc $(SRC)/bsym.inc $(SRC)/geq0.inc \
                $(SRC)/read.inc

wfn_print.f:    $(SRC)/wfn_print.F
wfn_print.o:    wfn_print.f $(SRC)/system.h $(SRC)/fft.inc \
                $(DEST)/irat.inc $(SRC)/cppt.inc $(SRC)/g_loc.inc \
                $(SRC)/fileopen.inc

wfopts.f:       $(SRC)/wfopts.F
wfopts.o:       wfopts.f $(SRC)/system.h $(SRC)/elct.inc $(SRC)/ions.inc \
                $(SRC)/pslo.inc $(SRC)/nlps.inc $(SRC)/atwf.inc \
                $(SRC)/kpts.inc $(SRC)/kpnt.inc $(SRC)/clas.inc \
                $(SRC)/sfac.inc $(SRC)/coor.inc $(SRC)/soft.inc \
                $(SRC)/bsym.inc $(SRC)/ddip.inc $(SRC)/cplngs.inc \
                $(SRC)/spin.inc

wr30wfn.f:      $(SRC)/wr30wfn.F
wr30wfn.o:      wr30wfn.f $(SRC)/system.h $(DEST)/irat.inc \
                $(SRC)/kpts.inc $(SRC)/bsym.inc $(SRC)/spin.inc \
                $(SRC)/geq0.inc $(SRC)/atwf.inc $(SRC)/ions.inc \
                $(SRC)/cnst.inc $(SRC)/pslo.inc $(SRC)/cppt.inc

wrccfl.f:       $(SRC)/wrccfl.F
wrccfl.o:       wrccfl.f $(SRC)/system.h $(SRC)/bsym.inc $(SRC)/ropt.inc \
                $(SRC)/fileopen.inc

wrener.f:       $(SRC)/wrener.F
wrener.o:       wrener.f $(SRC)/system.h $(SRC)/store.inc $(SRC)/ions.inc \
                $(SRC)/ropt.inc $(SRC)/clas.inc $(SRC)/temps.inc \
                $(SRC)/mm_input.inc $(SRC)/nlps.inc $(SRC)/fint.inc \
                $(SRC)/spin.inc $(SRC)/ener.inc $(SRC)/pslo.inc \
                $(SRC)/adat.inc $(SRC)/cnst.inc $(SRC)/response_p.inc \
                $(SRC)/mm_dim.inc $(SRC)/kpts.inc $(SRC)/kpnt.inc \
                $(SRC)/conv.inc $(SRC)/strs.inc $(SRC)/rmas.inc \
                $(SRC)/coor.inc $(SRC)/metr.inc

wrgeo.f:        $(SRC)/wrgeo.F
wrgeo.o:        wrgeo.f $(SRC)/system.h $(SRC)/ions.inc $(SRC)/adat.inc \
                $(SRC)/mm_dim.inc $(SRC)/mm_input.inc $(DEST)/irat.inc \
                $(SRC)/ropt.inc $(SRC)/cnst.inc $(SRC)/store.inc \
                $(SRC)/fileopen.inc

wrintf.f:       $(SRC)/wrintf.F
wrintf.o:       wrintf.f $(SRC)/system.h $(SRC)/filn.inc $(SRC)/kpts.inc \
                $(SRC)/store.inc $(SRC)/fileopen.inc $(SRC)/kpnt.inc \
                $(SRC)/func.inc $(SRC)/isos.inc $(SRC)/ions.inc \
                $(SRC)/ragg.inc

write_pp.f:     $(SRC)/write_pp.F
write_pp.o:     write_pp.f $(SRC)/system.h $(SRC)/sgpp.inc \
                $(SRC)/func.inc $(SRC)/dpot.inc $(SRC)/ions.inc \
                $(SRC)/fileopen.inc

wr_temps.f:     $(SRC)/wr_temps.F
wr_temps.o:     wr_temps.f $(SRC)/system.h $(SRC)/cnst.inc \
                $(SRC)/pimd.inc $(SRC)/nose.inc $(SRC)/fileopen.inc

wv30.f:         $(SRC)/wv30.F
wv30.o:         wv30.f $(SRC)/system.h $(SRC)/filn.inc $(SRC)/nose.inc \
                $(SRC)/benc.inc $(SRC)/kpts.inc $(SRC)/store.inc \
                $(SRC)/fileopen.inc $(SRC)/adat.inc $(SRC)/ions.inc \
                $(SRC)/symm.inc $(SRC)/elct.inc $(SRC)/ener.inc \
                $(SRC)/metr.inc $(SRC)/cell.inc $(SRC)/poin.inc \
                $(SRC)/kpnt.inc $(SRC)/pimd.inc $(SRC)/clas.inc \
                $(SRC)/spin.inc $(SRC)/cotr.inc $(SRC)/lscal.inc \
                $(DEST)/irat.inc $(SRC)/bsym.inc $(SRC)/mm_dim.inc \
                $(SRC)/mm_extrap.inc

x1fft.f:        $(SRC)/x1fft.F
x1fft.o:        x1fft.f $(SRC)/system.h $(SRC)/fft.inc

xcener.f:       $(SRC)/xcener.F
xcener.o:       xcener.f $(SRC)/system.h $(SRC)/tbxc.inc $(SRC)/spin.inc \
                $(SRC)/fft.inc $(SRC)/func.inc

xcstr.f:        $(SRC)/xcstr.F
xcstr.o:        xcstr.f $(SRC)/system.h $(SRC)/cnst.inc $(SRC)/cppt.inc \
                $(SRC)/strs.inc $(SRC)/tbxc.inc $(SRC)/spin.inc \
                $(SRC)/geq0.inc

ylmr2.f:        $(SRC)/ylmr2.F
ylmr2.o:        ylmr2.f $(SRC)/cnst.inc $(SRC)/geq0.inc

ylmr.f:         $(SRC)/ylmr.F
ylmr.o:         ylmr.f $(SRC)/cnst.inc

ympfft.f:       $(SRC)/ympfft.F
ympfft.o:       ympfft.f $(SRC)/system.h $(SRC)/fft.inc

zdiis.f:        $(SRC)/zdiis.F
zdiis.o:        zdiis.f $(SRC)/system.h $(SRC)/ener.inc $(SRC)/geq0.inc \
                $(SRC)/linres.inc

zhip.f:         $(SRC)/zhip.F
zhip.o:         zhip.f $(SRC)/system.h $(SRC)/isos.inc $(SRC)/cnst.inc \
                $(SRC)/cppt.inc $(SRC)/gvec.inc $(SRC)/qspl.inc \
                $(SRC)/geq0.inc

znum_mat.f:     $(SRC)/znum_mat.F
znum_mat.o:     znum_mat.f $(SRC)/system.h $(SRC)/spin.inc \
                $(SRC)/cppt.inc $(SRC)/geq0.inc $(SRC)/cnst.inc \
                $(SRC)/g_loc.inc $(SRC)/metr.inc


# create a regular timestamped cpmd package from the cvs tree
gtar-cpmd  :
	@( d=`date +%Y%m%d` ; b=`basename $$PWD` ; cd .. ;		\
	tar -c --exclude \*,v --exclude \*.bak --exclude \*~ --exclude CVS	\
	--exclude \*.o --exclude \*.a --exclude \*.x --exclude \*.log 		\
	--exclude \*.out --exclude \*.prj --exclude \*.chk			\
	--exclude MM_Interface --exclude Gromos 				\
	--exclude \*.orig --exclude \*.rej -zvvf $$b-$$d.tar.gz $$b &&	\
	echo successfully created $$b-$$d-tar.gz ; cd $$b )

# create a QM/MM timestamped cpmd package from the cvs tree
gtar-qmmm :
	@( d=`date +%Y%m%d` ; b=`basename $$PWD` ; cd .. ;		\
	tar -c --exclude \*,v --exclude \*.bak --exclude \*~ --exclude CVS	\
	--exclude \*.o --exclude \*.a --exclude \*.x --exclude \*.log 		\
	--exclude \*.out --exclude \*.prj --exclude \*.chk			\
	--exclude \*.orig --exclude \*.rej -zvvf $$b-$$d.tar.gz $$b &&	\
	echo successfully created $$b-$$d-tar.gz ; cd $$b )


tar   :
	tar -cvf code.tar mkconfig.sh *OBJ* */mm_diff */QMMMHELP.html *F *inc *c *h */*F */*h  
	echo 'code.tar created'  

