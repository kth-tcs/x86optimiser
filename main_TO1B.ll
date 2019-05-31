; ModuleID = 'main.cc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: uwtable
define i32 @main(i32 %argc, i8** %argv) #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i8**, align 8
  %itr = alloca i32, align 4
  %seed = alloca i32, align 4
  %i = alloca i32, align 4
  store i32 0, i32* %1
  store i32 %argc, i32* %2, align 4
  store i8** %argv, i8*** %3, align 8
  %4 = load i32* %2, align 4
  %5 = icmp sgt i32 %4, 1
  br i1 %5, label %6, label %11

; <label>:6                                       ; preds = %0
  %7 = load i8*** %3, align 8
  %8 = getelementptr inbounds i8** %7, i64 1
  %9 = load i8** %8, align 8
  %10 = call i32 @atoi(i8* %9) #4
  br label %12

; <label>:11                                      ; preds = %0
  br label %12

; <label>:12                                      ; preds = %11, %6
  %13 = phi i32 [ %10, %6 ], [ 1024, %11 ]
  store i32 %13, i32* %itr, align 4
  %14 = load i32* %2, align 4
  %15 = icmp sgt i32 %14, 2
  br i1 %15, label %16, label %21

; <label>:16                                      ; preds = %12
  %17 = load i8*** %3, align 8
  %18 = getelementptr inbounds i8** %17, i64 2
  %19 = load i8** %18, align 8
  %20 = call i32 @atoi(i8* %19) #4
  br label %22

; <label>:21                                      ; preds = %12
  br label %22

; <label>:22                                      ; preds = %21, %16
  %23 = phi i32 [ %20, %16 ], [ 0, %21 ]
  store i32 %23, i32* %seed, align 4
  %24 = load i32* %seed, align 4
  call void @srand(i32 %24) #5
  store i32 0, i32* %i, align 4
  br label %25

; <label>:25                                      ; preds = %32, %22
  %26 = load i32* %i, align 4
  %27 = load i32* %itr, align 4
  %28 = icmp slt i32 %26, %27
  br i1 %28, label %29, label %35

; <label>:29                                      ; preds = %25
  %30 = call i32 @rand() #5
  %31 = call i32 @_Z3p01i(i32 %30)
  br label %32

; <label>:32                                      ; preds = %29
  %33 = load i32* %i, align 4
  %34 = add nsw i32 %33, 1
  store i32 %34, i32* %i, align 4
  br label %25

; <label>:35                                      ; preds = %25
  ret i32 0
}

; Function Attrs: nounwind readonly
declare i32 @atoi(i8*) #1

; Function Attrs: nounwind
declare void @srand(i32) #2

declare i32 @_Z3p01i(i32) #3

; Function Attrs: nounwind
declare i32 @rand() #2

attributes #0 = { uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readonly "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind readonly }
attributes #5 = { nounwind }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"Ubuntu clang version 3.5.2-3ubuntu1 (tags/RELEASE_352/final) (based on LLVM 3.5.2)"}
