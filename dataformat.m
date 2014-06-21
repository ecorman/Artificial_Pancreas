function [Index,Date,Time,Timestamp,TempBasalAmount,BolusWizardData,Raw_Type,Raw_Values,raw2]=dataformat(file)

% This is the primary function for extracting the data from the xls file
% with pump and sensor data supplied by the user

warning off

[Data,Text,raw]=xlsread(file);

%raw with extraneous headers removed
raw(1:9,:)=[];


% Removing Nan [Not a Number] values from cells, which were generated by matlab upon import of the excel .xls file-raw, raw2, and raw3 are
% used

% finding size of raw, for for loop evaluation
[x,y]=size(raw);

% raw2, raw data converted to string format, in cells, using for loops
raw2{x,y}=0;
for i=1:x
    for j=1:y
        if isnumeric(raw{i,j})==1
            raw2{i,j}=num2str(raw{i,j});
        else
            raw2{i,j}=raw{i,j};
        end
    end
end

%raw 3, removal of NaN [Not a Number] values, using for loops
raw3{x,y}=0;
for ii=1:x
    for jj=1:y
        if strcmp('NaN',raw2{ii,jj})==1
            raw3{ii,jj}=[];
        else 
            raw3{ii,jj}=raw2{ii,jj};
        end
    end
end
    
% Converting string cells in raw3 that were previously number cells in raw variable,
% back in to number cells, using for loops
for iii=1:x
    for jjj=1:y
        if (isnumeric(raw{iii,jjj})==1)&&(~isnumeric(raw3{iii,jjj}))
            raw{iii,jjj}=str2num(raw3{iii,jjj});
        else 
            raw{iii,jjj}=raw3{iii,jjj};
        end
    end
end
            

%Index array
Index=raw(2:end,1);

%Removing 'Index' from Index array
for nnn=1:length(Index)
    if (strcmp(Index(nnn),'Index')==1)
        Index(nnn)=[];
    else 
        break
    end
end


%Serial Date Array
SerialDate=raw(2:end,2);
Date=SerialDate;

%Removing 'Date' from Date array
for nnn=1:length(Date)
    if (strcmp(Date(nnn),'Date')==1)
        Date(nnn)=[];
    else 
        break
    end
end


% Serial Time
Time=raw(2:end,3);

%Removing 'Time' from Time array
for nnn=1:length(Time)
    if (strcmp(Time(nnn),'Time')==1)
        Time(nnn)=[];
    else 
        break
    end
end


% Serial Timestamp

Timestamp=raw(2:end,4);

%Removing 'Timestamp' from Timestamp array
for nnn=1:length(Timestamp)
    if (strcmp(Timestamp(nnn),'Timestamp')==1)
        Timestamp(nnn)=[];
    else 
        break
    end
end

% BG Reading [mg/dL]

BGReading_mgdL=raw(2:end,6);

%Removing 'BG Reading (mg/dL)' from BGReading_mgdL array
for nnn=1:length(BGReading_mgdL)
    if (strcmp(BGReading_mgdL(nnn),'BG Reading (mg/dL)')==1)
        BGReading_mgdL(nnn)=[];
    else 
        break
    end
end


% Temp Basal Amount [U/h]

TempBasalAmount=raw(2:end,8);

%Removing 'Temp Basal Amount (U/h)' from TempBasalAmount array
for nnn=1:length(TempBasalAmount)
    if (strcmp(TempBasalAmount(nnn),'Temp Basal Amount (U/h)')==1)
        TempBasalAmount(nnn)=[];
    else 
        break
    end
end

% Removing null values from Temp Basal Amount
TempBasalAmount(cellfun(@isempty,TempBasalAmount)) = [];


%Sensor Calibration BG [mg/dL]

SensorCalibrationBG_mgdL=raw(2:end,30);

%Removing 'Sensor Calibration BG (mg/dL)' from SensorCalibrationBG_mgdL array
for nnn=1:length(SensorCalibrationBG_mgdL)
    if (strcmp(SensorCalibrationBG_mgdL(nnn),'Sensor Calibration BG (mg/dL)')==1)
        SensorCalibrationBG_mgdL(nnn)=[];
    else 
        break
    end
end

% Raw Type, records of programming actions occuring on the pump

Raw_Type=raw(2:end,34);

% Raw Values, Data describing programming actions occuring on the pump

Raw_Values=raw(2:end,35);

% Finding Blood Glucose Input in Raw_Values vector from 'BolusWizardBolusEstimate' entries, the entry which corresponds to one of the Raw_Type
% programming actions

% We find Blood Glucose Imput from 'BolusWizardBolusEstimate' by using
% while loops since the data within 'Raw_Values' has extraneous and irrelevant data that
% needs to be removed


% Bolus Wizard Data, has extraneous data, but has Blood Glucose Input from
% the corresponding Raw_Type cell 'BolusWizardBolusEstimate', we will extract
% Blood Glucose Input Values eventually using multiple loops

BolusWizardData=Raw_Values(strcmp('BolusWizardBolusEstimate',Raw_Type)==1);

% Corresponding Times for Bolus Wizard Data

Time_BolusWizardData=Time(strcmp('BolusWizardBolusEstimate',Raw_Type)==1);

% Removing null entries from Time_BolusWizardData

Time_BolusWizardData(cellfun(@isempty,BolusWizardData)) = [];


% Removing null entries from BolusWizardData
BolusWizardData(cellfun(@isempty,BolusWizardData)) = [];


% Loop 1-create uniform length for each indice of BolusWizardData

% pre loop initilization

% BolusWizardDataUniform-Equal Length Indices of BolusWizardData

BolusWizardDataUniform={0};

% counter
aa=1;

% Temporary Storage Variable
dd=0;

% while loop

while (aa<=length(BolusWizardData))
    cc=BolusWizardData(aa);
    dd=cell2mat(cc);
    ee=dd(1:50);
    if isempty(aa)~=1
        BolusWizardDataUniform{aa}=ee;
        aa=aa+1;
    end
end

%end of loop

% Transposed BolusWizardDataUniform

transposeBolusWizardDataUniform=BolusWizardDataUniform';

BolusWizardDataUniform=transposeBolusWizardDataUniform;

BolusWizardDataUniformMatrix=cell2mat(BolusWizardDataUniform);

characterlength=length(BolusWizardDataUniformMatrix(1,:));

% counter
a=1;

% Loop to Extract 'BG_INPUT=XXX' out of BolusWizardDataUniform Matrix

while a<=length(BolusWizardDataUniformMatrix(:,1))
    for b=1:characterlength
        if strcmp(BolusWizardDataUniformMatrix(a,b),',')~=1
            % BG input in one character per cell format
            bginputboluswizardmultiplecells{a,b}=BolusWizardDataUniformMatrix(a,b);
        else
            break
        end
    end
      a=a+1;
end

% Loop to combine mutiple horizontal cells in to a single horizontal cell
nRows = size(bginputboluswizardmultiplecells,1);
bginputboluswizard= cell(nRows,1);

for r = 1:nRows
    bginputboluswizard{r} = [bginputboluswizardmultiplecells{r,:}];
end

% flag
flag=0;

if length(cell2mat(bginputboluswizard(1,:)))<9
    flag=1;
end

% Removing 'BG_INPUT=' so that only numerical BG values are in the cell
% vector

%pre loop initialization

% BG values from bolus wizard [mg/dL]
bgboluswizard_mgdL={0};

%counter
aaa=1;

while aaa<=length(bginputboluswizard(:,1))
    for bbb=1:length(bginputboluswizard(1,:))
        if flag==1
         break
     else
        bginputboluswizardedited=cell2mat(bginputboluswizard(aaa,bbb));
        bginputboluswizardedited(1:9)=[];
        bgboluswizard_mgdL{aaa}=bginputboluswizardedited;
        end
    end
aaa=aaa+1;
end

bgboluswizard_mgdL=bgboluswizard_mgdL';

% bgboluswizard cell in double precision
bgboluswizarddouble_mgdL=str2double(bgboluswizard_mgdL);

% bgboluswizard_mmolL [mmol/L]

bgboluswizard_mmolL=char(bgboluswizarddouble_mgdL)/18.1;

% Removing any "0" bg input values from bgboluswizard_mgdL

for nnnn=1:length(bgboluswizarddouble_mgdL(bgboluswizarddouble_mgdL~=0))
    if bgboluswizarddouble_mgdL(nnnn)==0
        bgboluswizard_mgdL(nnnn)=[];
    end
end


% Basal Rate Start Timestamp

TimestampBasalRate=Timestamp(strcmp(Raw_Type,'BasalProfileStart'));


%BasalProfileStart, extracted from Raw Values, contains extraneous data
%that must be removed

BasalProfileStart=Raw_Values(strcmp(Raw_Type,'BasalProfileStart')==1);

% Removing Empty cells from TimeStampBasalRate
TimestampBasalRate(cellfun(@isempty,BasalProfileStart)) = [];

% Removing Empty Cells from BasalProfileStart
BasalProfileStart(cellfun(@isempty,BasalProfileStart)) = [];

% Loop to remove extraneous data from the begininning of BasalProfileStart

% pre loop initialization

% counter
ccc=1;

% vsriable
BasalProfileStartedited2={0};

% Removing extraneous data from the beginning of BasalProfileStart
while ccc<=length(BasalProfileStart(:,1))
    for ddd=1:length(bginputboluswizard(1,:))
        BasalProfileStartedited=cell2mat(BasalProfileStart(ccc,ddd));
        BasalProfileStartedited(1:40)=[];
        BasalProfileStartedited2{ccc}=BasalProfileStartedited;
    end
    ccc=ccc+1;
end

BasalProfileStartedited2=BasalProfileStartedited2';

% Loop-create uniform length for each indice of BasalProfileStartedited2

% pre loop initilization

% BasalProfileStartedited2Uniform-Equal Length Indices of BolusWizardData

BasalProfileStarteditedUniformMatrix={0};

% counter
ggg=1;

% Temporary Storage Variable
hhh=0;

% while loop
if length(BasalProfileStartedited2(1,:))>=20
while (ggg<=length(BasalProfileStartedited2))
    lll=BasalProfileStartedited2(ggg);
    hhh=cell2mat(lll);
    jjj=hhh(1:20);
    if isempty(ggg)~=1
        BasalProfileStarteditedUniformMatrix{ggg}=jjj;
        ggg=ggg+1;
    end
end
else
    return
end

% BasalProfileStarted needs to be converted in to matrix to perform other
% functions

BasalProfileStarteditedUniformMatrix=cell2mat(BasalProfileStarteditedUniformMatrix');




% Loop to remove more extraneous data if length of extraneous data is
% greater than length of 40

% counter
eee=1;

while eee<=length(BasalProfileStarteditedUniformMatrix(:,1))
    for zzz=1:length(BasalProfileStarteditedUniformMatrix(1,:))
        if strcmp(BasalProfileStarteditedUniformMatrix(eee,zzz),'R')~=1
            BasalProfileStarteditedUniformMatrix(eee,zzz)=BasalProfileStarteditedUniformMatrix(eee,zzz);
        else
            break
        end
    end
      eee=eee+1;
end

% Loop to extract data after 'RATE=XXX' from BasalProfileStarteditedUniformMatrix
%input variable, BasalRatemultiplecells
BasalRatemultiplecells={0};

% counter
xxx=1;

while xxx<=length(BasalProfileStarteditedUniformMatrix(:,1))
    for kkk=1:length(BasalProfileStarteditedUniformMatrix(1,:))
        if strcmp(BasalProfileStarteditedUniformMatrix(xxx,kkk),',')~=1
            % BG input in one character per cell format
            BasalRatemultiplecells{xxx,kkk}=BasalProfileStarteditedUniformMatrix(xxx,kkk);
        else
            break
        end
    end
      xxx=xxx+1;
end

% Loop to combine mutiple horizontal cells in to single horizontal cell
nRows = size(BasalRatemultiplecells,1);
BasalRatetext= cell(nRows,1);

for r = 1:nRows
    BasalRatetext{r} = [BasalRatemultiplecells{r,:}];
end

BasalRateMatrix=cell2mat(BasalRatetext);


% Removing 'Rate=' so that only numerical values are in the cell
% vector BasalRate

Basal=BasalRateMatrix(:,6:end);