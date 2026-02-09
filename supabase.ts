
import { createClient } from '@supabase/supabase-js';

// Configurações exatas do projeto fornecidas pelo usuário
const supabaseUrl = 'https://tlpmspfnswaxwqzmwski.supabase.co';
const supabaseAnonKey = 'sb_publishable_a_t5QoKSL53wf1uT6GjqYg_wk2ENe-9';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
