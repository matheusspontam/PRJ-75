#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXPATH 256


int ReadInt(FILE *arq, char* nome) {
    int valor;
    char* ptr;
    char linha[500];
    int len;

    ptr = 0x0;
    while(ptr == 0x0) {
        fgets(linha, 500, arq);
        ptr = strstr(linha,nome);
    }
    len = strlen(nome);
    valor = atoi(ptr+len);
    return(valor);
}

double ReadDouble(FILE *arq, char* nome) {
    double valor;
    char* ptr;
    char linha[500];
    int len;

    ptr = 0x0;
    while(ptr == 0x0) {
        fgets(linha, 500, arq);
        ptr = strstr(linha,nome);
    }
    len = strlen(nome);
    valor = atof(ptr+len);
    return(valor);
}


char* FileSearch(FILE *arq, char* nome) {
    char* ptr;
    char linha[500];

    ptr = 0x0;
    while(ptr == 0x0) {
        fgets(linha, 500, arq);
        ptr = strstr(linha,nome);
    }
    return(ptr);
}

void ReadVet(FILE* arq, char* nome, double* vetor, int N) {

    char* ptr;
    char linha[500];
    int len;

    ptr = 0x0;
    while(ptr == 0x0) {
        fgets(linha, 500, arq);
        ptr = strstr(linha,nome);
    }
    len = strlen(nome);
    ptr = ptr + len - 1;
    for (int i = 0; i< N; i++){
        vetor[i] = atof(ptr+1);
        ptr = strchr(ptr+1,',');
    }
}

void ReadCoef(FILE* arq, int NAlpha, int NVet, double* Vet0, double* Vet1, double* Vet2, double* Vet3, double* Vet4, double* Vet5) {

    char* ptr;
    char linha[500];
    double aux;
    char* numbers = "01234567890-+Ee.";
    double VAux[6][NAlpha];


    for (int i = 0; i < NAlpha ; i++){
            ptr = 0x0;
            while ( ptr == 0x0) {
                fgets(linha, 500, arq);
                ptr = strpbrk(linha, numbers);
            }
            aux = atof(ptr);
            for (int j = 0; j < NVet ; j++){
                ptr++;
                ptr = strchr(ptr,' ');
                ptr = strpbrk(ptr, numbers);
                aux = atof(ptr);
                VAux[j][i] = aux;
            }
    }

    for (int i = 0; i < NAlpha; i++) {
        Vet0[i] = VAux[0][i];
    }
    if (NVet >= 2) {
        for (int i = 0; i < NAlpha; i++) {
           Vet1[i] = VAux[1][i];
        }
    }
    if (NVet >= 3) {
        for (int i = 0; i < NAlpha; i++) {
           Vet2[i] = VAux[2][i];
        }
    }
    if (NVet >= 4) {
        for (int i = 0; i < NAlpha; i++) {
           Vet3[i] = VAux[3][i];
        }
    }
    if (NVet >= 5) {
        for (int i = 0; i < NAlpha; i++) {
           Vet4[i] = VAux[4][i];
        }
    }
    if (NVet == 6) {
        for (int i = 0; i < NAlpha; i++) {
           Vet5[i] = VAux[5][i];
        }
    }

    aux = 1;

}

int read_arg(int argc, char *argv[], char *input_name, char *output_name, int* delta0, int* ddelta, int* ndelta)
// argc: no. de parametros, incluindo o nome do programa .exe
// argv: vetor de apontadores para char, com argc elementos, sendo o primeiro
//       um apontador para uma string contendo o nome do programa .exe
// retorno: 0: interpretacao completa, continuar execucao
//          1: impressao de tela de ajuda, terminar execucao
{
   char ch;     // caractere de interpretacao dos parametros de linha de comando
   char* str;   // ponteiro para string de entrada na linha de comando
   char aux_str[MAXPATH]; // ponteiro para string auxiliar

   while (--argc > 0 ) {
      if ( (*++argv)[0] != '-')
	     printf("Argumento ilegal: %s\n\r",*argv);
      else {
	     ch = *++argv[0];
	     switch (ch) {
	        case '?':   // Ajuda
               printf("Rundatcom2 -i:input_name.dat -o:output_name -delta0:delta0 -deltad:ddelta -deltan:ndelta\n\r");
               printf("input_name.dat: nome do arquivo de entrada com dados do missil (for005_anti_uav.dat)\n\r");
               printf("output_name.dat: nome do arquivo de saida com dados do missil (coeficientes.dat)\n\r");
               printf("delta0: valor inicial de delta (graus)\n\r");
               printf("ddelta: incremento de delta (graus)\n\r");
               printf("ndelta: numero de deltas(graus)\n\r");
               printf("\n\r");
               printf("ex: \n\r");
               printf("Rundatcom2 -i:for005_anti_uav.dat -o:coeficientes.dat -delta0:-20 -deltad:2 -ddeltan:21 \n\r");
               printf("Roda o DATCOM para o arquivo for005_anti_uav.dat para delta = -20, -18, ... 18, 20\n\r");
               printf("Resultados no arquivo coeficientes.dat\n\r");
	       return(1);

	       case 'i':   // Nome do arquivo de entrada
	       case 'I':
	          if ( *++argv[0] == ':' )
		         strncpy(input_name,++argv[0],MAXPATH-1);
	          else
               printf("Argumento ilegal: -%c%s\n\r",ch,argv[0]);
	          break;

	       case 'o':   // Nome do arquivo de saida
	       case 'O':
	          if ( *++argv[0] == ':' )
		         strncpy(output_name,++argv[0],MAXPATH-1);
	          else
               printf("Argumento ilegal: -%c%s\n\r",ch,argv[0]);
	          break;


	       case 'd':   // Entrada de vetor de deltas
	       case 'D':
	          str = ++argv[0];
	          if ( strncmp(str,"elta0:",6) == 0 ) {             // delta inicial
		         argv[0] += 6;
		         strncpy(aux_str,argv[0],MAXPATH-1);
		         *delta0 = atoi(aux_str);
	          }
	          else if ( strncmp(str,"eltad:",6) == 0 ) {        // incremento de delta
		         argv[0] += 6;
		         strncpy(aux_str,argv[0],MAXPATH-1);
		         *ddelta = atoi(aux_str);
	          }
	          else if ( strncmp(str,"eltan:",6) == 0 ) {        // numero de deltas
		         argv[0] += 6;
		         strncpy(aux_str,argv[0],MAXPATH-1);
		         *ndelta = atoi(aux_str);
	          }
	          else
		          printf("Argumento ilegal: -%c%s\n\r",ch,str);
	          break;

	       default:
	           printf("Argumento ilegal: -%c%s\n\r",ch,++argv[0]);
	          break;
	       }
         }
      }
      return(0);
}


int main(int argc, char *argv[])
// argc: no. de parametros, incluindo o nome do programa .exe
// argv: vetor de apontadores para char, com argc elementos, sendo o primeiro
//       um apontador para uma string contendo o nome do programa .exe
// retorno: 0: simulacao completa sem erros
//          1: erro de execucao
{

    FILE *arq, *res, *out, *arq_conf;
    int NDelta = 21;
    int Delta0 = -20;
    int dDelta = 2;

    char input_name[MAXPATH] = "for005_anti_uav.dat";
    char output_name[MAXPATH] = "coeficientes.dat";

    int iDelta, iMach, iAlpha;
    double VDelta[MAXPATH];
    double delta;
    int NMach, NAlpha;
    int First = 1;
    int i;
    double XCG;
    char linha[500];
    char aux_str[500];
    int len;
    char* ptr;

    if (read_arg(argc, argv, input_name, output_name, &Delta0, &dDelta, &NDelta )) {
        return(-1);
    }

    printf("Arquivo de entrada: %s\n\r", input_name);
    printf("Arquivo de saida: %s\n\r", output_name);
    printf("Delta0: %d\n\r", Delta0);
    printf("dDelta: %d\n\r", dDelta);
    printf("NDelta: %d\n\r\n\r", NDelta);

    for ( iDelta = 0; iDelta < NDelta ; iDelta++){
        delta = Delta0 + iDelta*dDelta;
        VDelta[iDelta] = delta;
    }

    arq_conf = fopen(input_name,"r");
    XCG = ReadDouble(arq_conf, "XCG=");
    fclose(arq_conf);

    out = fopen(output_name,"w");
    fprintf(out, "%f ",XCG);
    fprintf(out, "%d ",NDelta);
    for ( iDelta = 0 ; iDelta < NDelta ; iDelta++){
        fprintf(out, "%e ",VDelta[iDelta]);
    }

    for ( iDelta = 0; iDelta < NDelta ; iDelta++){

       delta = VDelta[iDelta];
       printf("Delta: %d\n", (int)delta);

       arq = fopen("for005.dat","w");
       arq_conf = fopen(input_name,"r");

       while ( fgets(linha, 500, arq_conf) != NULL ) {
          if ( strstr(linha,"DELTA") == NULL){
            fprintf(arq,"%s", linha);
          }
          else {
            ptr = strstr(linha,"=");
            len = ptr - linha + 1;
            for (i = 0 ; i < 500 ; i++){
               aux_str[i] = 0;
            }
            strncpy(aux_str,linha,len);
            fprintf(arq,"%s",aux_str);
            fprintf(arq," 0.,%f,0.,%f\n",(double)delta,(double)-delta);
           }
       }

       fclose(arq);
       fclose(arq_conf);
//------------------------------------------------------------------------------

       system("Misdat.exe");

       res = fopen("for006.dat","r");

       NAlpha = ReadInt(res, "NALPHA=");
       double VAlpha[NAlpha];
       ReadVet(res, "ALPHA=", VAlpha, NAlpha);

       NMach = ReadInt(res,"NMACH=");
       double VMach[NMach];
       ReadVet(res, "MACH=", VMach, NMach);


        double Vet1[NAlpha], Vet2[NAlpha], Vet3[NAlpha], Vet4[NAlpha], Vet5[NAlpha], Vet6[NAlpha];
        double Hinge11[NMach][NAlpha], Hinge12[NMach][NAlpha], Hinge13[NMach][NAlpha], Hinge14[NMach][NAlpha];
        double Hinge21[NMach][NAlpha], Hinge22[NMach][NAlpha], Hinge23[NMach][NAlpha], Hinge24[NMach][NAlpha];
        double CN[NMach][NAlpha], CM[NMach][NAlpha], CA[NMach][NAlpha], CY[NMach][NAlpha], CLN[NMach][NAlpha], CLL[NMach][NAlpha];
        double CL[NMach][NAlpha], CD[NMach][NAlpha], CL_CD[NMach][NAlpha], XCP[NMach][NAlpha];
        double CNA[NMach][NAlpha], CMA[NMach][NAlpha], CYB[NMach][NAlpha], CLNB[NMach][NAlpha], CLLB[NMach][NAlpha];
        double CNQ[NMach][NAlpha], CMQ[NMach][NAlpha], CAQ[NMach][NAlpha], CNAD[NMach][NAlpha], CMAD[NMach][NAlpha];
        double CYR[NMach][NAlpha], CLNR[NMach][NAlpha], CLLR[NMach][NAlpha], CYP[NMach][NAlpha], CLNP[NMach][NAlpha], CLLP[NMach][NAlpha];

        for ( iMach=0 ; iMach < NMach ; iMach++){
           FileSearch(res, "MACH NO");
           FileSearch(res, "ALPHA");
           ReadCoef(res, NAlpha, 4, Vet1, Vet2, Vet3, Vet4, Vet5, Vet6);
           for (int iAlpha = 0; iAlpha < NAlpha; iAlpha++){
               Hinge11[iMach][iAlpha] = Vet1[iAlpha];
               Hinge12[iMach][iAlpha] = Vet2[iAlpha];
               Hinge13[iMach][iAlpha] = Vet3[iAlpha];
               Hinge14[iMach][iAlpha] = Vet4[iAlpha];
           }

           FileSearch(res, "ALPHA");
           ReadCoef(res, NAlpha, 4, Vet1, Vet2, Vet3, Vet4, Vet5, Vet6);
           for ( iAlpha = 0; iAlpha < NAlpha; iAlpha++){
               Hinge21[iMach][iAlpha] = Vet1[iAlpha];
               Hinge22[iMach][iAlpha] = Vet2[iAlpha];
               Hinge23[iMach][iAlpha] = Vet3[iAlpha];
               Hinge24[iMach][iAlpha] = Vet4[iAlpha];
           }

           FileSearch(res, "ALPHA");
           ReadCoef(res, NAlpha, 6, Vet1, Vet2, Vet3, Vet4, Vet5, Vet6);
           for ( iAlpha = 0; iAlpha < NAlpha; iAlpha++){
               CN[iMach][iAlpha]  = Vet1[iAlpha];
               CM[iMach][iAlpha]  = Vet2[iAlpha];
               CA[iMach][iAlpha]  = Vet3[iAlpha];
               CY[iMach][iAlpha]  = Vet4[iAlpha];
               CLN[iMach][iAlpha] = Vet5[iAlpha];
               CLL[iMach][iAlpha] = Vet6[iAlpha];
           }

           FileSearch(res, "ALPHA");
           ReadCoef(res, NAlpha, 4, Vet1, Vet2, Vet3, Vet4, Vet5, Vet6);
           for ( iAlpha = 0; iAlpha < NAlpha; iAlpha++){
               CL[iMach][iAlpha]    = Vet1[iAlpha];
               CD[iMach][iAlpha]    = Vet2[iAlpha];
               CL_CD[iMach][iAlpha] = Vet3[iAlpha];
               XCP[iMach][iAlpha]   = Vet4[iAlpha];
           }

           FileSearch(res, "ALPHA");
           ReadCoef(res, NAlpha, 5, Vet1, Vet2, Vet3, Vet4, Vet5, Vet6);
           for ( iAlpha = 0; iAlpha < NAlpha; iAlpha++){
               CNA[iMach][iAlpha]  = Vet1[iAlpha];
               CMA[iMach][iAlpha]  = Vet2[iAlpha];
               CYB[iMach][iAlpha]  = Vet3[iAlpha];
               CLNB[iMach][iAlpha] = Vet4[iAlpha];
               CLLB[iMach][iAlpha] = Vet5[iAlpha];
           }
           FileSearch(res, "ALPHA");
           ReadCoef(res, NAlpha, 5, Vet1, Vet2, Vet3, Vet4, Vet5, Vet6);
           for ( iAlpha = 0; iAlpha < NAlpha; iAlpha++){
               CNQ[iMach][iAlpha]  = Vet1[iAlpha];
               CMQ[iMach][iAlpha]  = Vet2[iAlpha];
               CAQ[iMach][iAlpha]  = Vet3[iAlpha];
               CNAD[iMach][iAlpha] = Vet4[iAlpha];
               CMAD[iMach][iAlpha] = Vet5[iAlpha];
           }
           FileSearch(res, "ALPHA");
           ReadCoef(res, NAlpha, 6, Vet1, Vet2, Vet3, Vet4, Vet5, Vet6);
           for ( iAlpha = 0; iAlpha < NAlpha; iAlpha++){
               CYR[iMach][iAlpha]  = Vet1[iAlpha];
               CLNR[iMach][iAlpha] = Vet2[iAlpha];
               CLLR[iMach][iAlpha] = Vet3[iAlpha];
               CYP[iMach][iAlpha]  = Vet4[iAlpha];
               CLNP[iMach][iAlpha] = Vet5[iAlpha];
               CLLP[iMach][iAlpha] = Vet6[iAlpha];
           }
           printf("   Mach: %f\n", VMach[iMach]);

        } // Fim da leitura dos Machs
        fclose(res);

        if (First) {
            fprintf(out, "%d ",NMach);
            for ( iMach = 0 ; iMach < NMach ; iMach++){
                fprintf(out, "%e ",VMach[iMach]);
            }

            fprintf(out, "%d ",NAlpha);
            for ( iAlpha = 0 ; iAlpha < NAlpha ; iAlpha++){
                fprintf(out, "%e ",VAlpha[iAlpha]);
            }
            First = 0;
        }

        for ( iMach = 0 ; iMach < NMach ; iMach++){
            for ( iAlpha = 0 ; iAlpha < NAlpha ; iAlpha++ ){
                fprintf(out, "%e ", Hinge11[iMach][iAlpha]);
                fprintf(out, "%e ", Hinge12[iMach][iAlpha]);
                fprintf(out, "%e ", Hinge13[iMach][iAlpha]);
                fprintf(out, "%e ", Hinge14[iMach][iAlpha]);

                fprintf(out, "%e ", Hinge21[iMach][iAlpha]);
                fprintf(out, "%e ", Hinge22[iMach][iAlpha]);
                fprintf(out, "%e ", Hinge23[iMach][iAlpha]);
                fprintf(out, "%e ", Hinge24[iMach][iAlpha]);

                fprintf(out, "%e ", CN[iMach][iAlpha]);
                fprintf(out, "%e ", CM[iMach][iAlpha]);
                fprintf(out, "%e ", CA[iMach][iAlpha]);
                fprintf(out, "%e ", CY[iMach][iAlpha]);
                fprintf(out, "%e ", CLN[iMach][iAlpha]);
                fprintf(out, "%e ", CLL[iMach][iAlpha]);

                fprintf(out, "%e ", CL[iMach][iAlpha]);
                fprintf(out, "%e ", CD[iMach][iAlpha]);
                fprintf(out, "%e ", CL_CD[iMach][iAlpha]);
                fprintf(out, "%e ", XCP[iMach][iAlpha]);

                fprintf(out, "%e ", CNA[iMach][iAlpha]);
                fprintf(out, "%e ", CMA[iMach][iAlpha]);
                fprintf(out, "%e ", CYB[iMach][iAlpha]);
                fprintf(out, "%e ", CLNB[iMach][iAlpha]);
                fprintf(out, "%e ", CLLB[iMach][iAlpha]);

                fprintf(out, "%e ", CNQ[iMach][iAlpha]);
                fprintf(out, "%e ", CMQ[iMach][iAlpha]);
                fprintf(out, "%e ", CAQ[iMach][iAlpha]);
                fprintf(out, "%e ", CNAD[iMach][iAlpha]);
                fprintf(out, "%e ", CMAD[iMach][iAlpha]);

                fprintf(out, "%e ", CYR[iMach][iAlpha]);
                fprintf(out, "%e ", CLNR[iMach][iAlpha]);
                fprintf(out, "%e ", CLLR[iMach][iAlpha]);
                fprintf(out, "%e ", CYP[iMach][iAlpha]);
                fprintf(out, "%e ", CLNP[iMach][iAlpha]);
                fprintf(out, "%e ", CLLP[iMach][iAlpha]);
            }
        }

    } // Fim do loop de deltas
    fclose(out);
    return 0;
}
