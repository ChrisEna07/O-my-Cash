-- TABLA DE TRANSACCIONES (Ingresos y Gastos)
CREATE TABLE public.transactions (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES auth.users NOT NULL,
    amount numeric NOT NULL,
    type text CHECK (type IN ('income', 'expense')) NOT NULL,
    category text NOT NULL, -- Arriendo, Ocio, Comida, etc.
    rule_category text CHECK (rule_category IN ('need', 'want', 'save')) NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- TABLA DE METAS DE AHORRO
CREATE TABLE public.savings_goals (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES auth.users NOT NULL,
    goal_name text NOT NULL,
    target_amount numeric NOT NULL,
    current_amount numeric DEFAULT 0,
    deadline date,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ACTIVAR SEGURIDAD DE FILA (RLS)
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.savings_goals ENABLE ROW LEVEL SECURITY;

-- POLÍTICAS: El usuario solo puede leer/escribir sus propios datos
CREATE POLICY "Users can manage their own transactions" 
ON public.transactions FOR ALL 
USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own goals" 
ON public.savings_goals FOR ALL 
USING (auth.uid() = user_id);

-- TABLA DE PERFILES DE USUARIO
CREATE TABLE public.profiles (
    id uuid REFERENCES auth.users NOT NULL PRIMARY KEY,
    full_name text,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver su propio perfil" 
ON public.profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Los usuarios pueden actualizar su propio perfil" 
ON public.profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Los usuarios pueden insertar su propio perfil" 
ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

