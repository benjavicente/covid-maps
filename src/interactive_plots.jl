### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 7a0d07f0-578a-11eb-359d-afc6edf042a0
begin
	in_pluto = @isdefined PlutoRunner
	if in_pluto
		using PlutoUI
		md"# Plots COVID19"
	end
end

# ╔═╡ bf11aa12-5788-11eb-2c7c-c979681e529d
begin
	using CSV
	using Dates
	using Statistics
	using DataFrames
	using Plots
end

# ╔═╡ 1031312c-5795-11eb-1df4-a71ffae9ba5d
begin
	if false
		using PlotlyJS
		plotlyjs()
	else
		gr()
	end
end;

# ╔═╡ e95448ec-578e-11eb-116f-8bde62ca2b8c
function moving_avarage(a::Vector, n::Int = 5)
	@assert length(a) ÷ 8 > n "n is to large for the array"
	[mean(a[max(1, i-n):min(i+n, end)]) for i in 1:length(a)]
end;

# ╔═╡ 5b05ded2-5795-11eb-020a-09c4f2bbc078
md"## UCI por región"

# ╔═╡ ead8c482-5788-11eb-1146-1f5095e4df4d
begin
	df_uci = CSV.read("../data/Datos-COVID19/output/producto8/UCI.csv", DataFrame)
end

# ╔═╡ 2be67732-578c-11eb-34a8-a799951cc203
begin
	dates = Date.(names(df_uci[4:end]));
	plot([], [], labels=nothing) # Empty plot
	for i in 1:size(df_uci, 1)
		uci_per_1000_people = 100_000 * Array(df_uci[i, 4:end]) / df_uci[i, 3]
		plot!(
			dates,
			moving_avarage(uci_per_1000_people, 5),
			labels=df_uci[i, 1],
			linewidth=1.5
		)
	end
	plot!(
		title="UCI por 100mil habitantes",
		legend=:outerright,
	)
end

# ╔═╡ 00285342-5794-11eb-30fb-cf6505a2a89f
begin
	plot(
		dates,
		moving_avarage(sum(Array.(eachrow(df_uci[:, 4:end])))),
		label=nothing,
		title="UCI Chile"
	)
end

# ╔═╡ 05010c5e-5796-11eb-39ce-e588ae1760d6
md"## Plan paso a paso"

# ╔═╡ 094cb4fc-5796-11eb-0d05-8356575e4b22
begin
	df_cuarentenas = CSV.read(
		"../data/Datos-COVID19/output/producto74/paso_a_paso.csv",
		DataFrame
	)
end

# ╔═╡ df7f2b0e-5796-11eb-3f9f-e5bdb7b07152
df_cuarentenas[df_cuarentenas["region_residencia"] .== "Arica y Parinacota", :]

# ╔═╡ 9d241c78-5797-11eb-25d8-2dcde74dd2df
# TODO: tratar de hacer unir esta tabla con lo de los casos actvos

# ╔═╡ Cell order:
# ╟─7a0d07f0-578a-11eb-359d-afc6edf042a0
# ╠═bf11aa12-5788-11eb-2c7c-c979681e529d
# ╠═1031312c-5795-11eb-1df4-a71ffae9ba5d
# ╠═e95448ec-578e-11eb-116f-8bde62ca2b8c
# ╟─5b05ded2-5795-11eb-020a-09c4f2bbc078
# ╠═ead8c482-5788-11eb-1146-1f5095e4df4d
# ╠═2be67732-578c-11eb-34a8-a799951cc203
# ╠═00285342-5794-11eb-30fb-cf6505a2a89f
# ╟─05010c5e-5796-11eb-39ce-e588ae1760d6
# ╠═094cb4fc-5796-11eb-0d05-8356575e4b22
# ╠═df7f2b0e-5796-11eb-3f9f-e5bdb7b07152
# ╠═9d241c78-5797-11eb-25d8-2dcde74dd2df
